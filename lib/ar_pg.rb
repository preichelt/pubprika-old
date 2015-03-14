module ArPg
  def blacklist_fields
    []
  end

  def fields_of_type(type)
    column_names.map {|cn| cn if columns_hash[cn].type == type}.compact.reject {|f| blacklist_fields.include?(f)}
  end

  def binary_fields
    fields_of_type(:binary)
  end

  def datetime_fields
    fields_of_type(:datetime)
  end

  def integer_fields
    fields_of_type(:integer)
  end

  def decimal_fields
    fields_of_type(:decimal)
  end

  def string_fields
    fields_of_type(:string)
  end

  def text_fields
    fields_of_type(:text)
  end

  def boolean_fields
    fields_of_type(:boolean)
  end

  def simple_fields
    integer_fields + string_fields + text_fields + boolean_fields
  end

  def include_has_many
    []
  end

  def include_has_many_reflections
    include_has_many
      .map {|hm| reflect_on_association(hm)}
      .map {|r| {
        table_name: r.plural_name,
        results_name: "#{r.plural_name.singularize}_results",
        model: r.plural_name.classify.constantize,
        order: "#{r.options.has_key?(:order) ? r.options[:order].split(", ").map {|o| "#{r.plural_name}.#{o}"}.join(", ") : ""}",
        fk: "#{r.options.has_key?(:foreign_key) ? r.options[:foreign_key] : "#{table_name.singularize}_id"}"}}
      .map {|h| Hashie::Mash.new(h)}
  end

  def include_belongs_to
    []
  end

  def include_belongs_to_reflections
    include_belongs_to
      .map {|bt| reflect_on_association(bt)}
      .map {|r| {
        table_name: r.plural_name,
        results_name: "#{r.plural_name.singularize}_results",
        model: r.plural_name.classify.constantize,
        order: "#{r.options.has_key?(:order) ? r.options[:order].split(", ").map {|o| "#{r.plural_name}.#{o}"}.join(", ") : ""}",
        fk: "#{r.options[:foreign_key] || "#{r.plural_name.singularize}_id"}"}}
      .map {|h| Hashie::Mash.new(h)}
  end

  def for_ar_pg
    self.select("
      #{simple_fields.map {|f| "#{table_name}.#{f}"}*', '}
      #{binary_fields.count > 0 ? ', ' : ''}
      #{binary_fields.map {|f| "encode(#{table_name}.#{f}, 'base64') as #{f}"}*', '}
      #{datetime_fields.count > 0 ? ', ' : ''}
      #{datetime_fields.map {|f| "to_char(timezone('UTC', cast(#{table_name}.#{f} as timestamp(0))), 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') as #{f}"}*', '}
      #{decimal_fields.count > 0 ? ', ' : ''}
      #{decimal_fields.map {|f| "to_char(#{table_name}.#{f}, 'FM99999999999999999999.9999999999') as #{f}"}*', '}
      #{include_belongs_to.count > 0 ? ', ' : ''}
      #{include_belongs_to_reflections.map {|bt| "(SELECT row_to_json(#{bt.results_name}) from (#{bt.model.for_ar_pg.to_sql} where #{bt.table_name}.id = #{table_name}.#{bt.fk}) #{bt.results_name}) as #{bt.table_name.singularize}"}*', '}
      #{include_has_many.count > 0 ? ', ' : ''}
      #{include_has_many_reflections.map {|hm| "(CASE WHEN (SELECT count(*) from #{hm.table_name} where #{hm.table_name}.#{hm.fk} = #{table_name}.id) = 0 THEN '[]' ELSE (SELECT json_agg(#{hm.results_name}) from (#{hm.model.for_ar_pg.to_sql} where #{hm.table_name}.#{hm.fk} = #{table_name}.id #{hm.order.length > 0 ? "ORDER BY #{hm.order}" : ""}) as #{hm.results_name}) END) as #{hm.table_name}"}*', '}
    ")
  end

  def ar_pg_wrap(query, key = "objects")
    ActiveRecord::Base.connection.execute(
      "SELECT json_agg(query_results) as #{key}
        FROM (
          #{query.to_sql}
        ) query_results"
    ).first
  end

  def ar_pg_wrap_find(query, key = "objects")
    results = self.ar_pg_wrap(query, key)[key]
    results[1..-1][0..-2] if results
  end

  def ar_pg_wrap_array(query, key = "objects")
    ActiveRecord::Base.connection.execute(
      "SELECT to_json(array(#{query.to_sql})) as #{key}"
    ).first
  end

  def ar_pg_package(objs)
    json = ""
    objs.each do |obj|
      key = obj.keys.first
      if json == ""
        if obj[key].nil?
          json = "\"#{key}\":null"
        else
          json = "\"#{key}\":#{obj[key]}"
        end
      else
        if obj[key].nil?
          json = "#{json},\"#{key}\":null"
        else
          json = "#{json},\"#{key}\":#{obj[key]}"
        end
      end
    end
    "{#{json}}"
  end
end
