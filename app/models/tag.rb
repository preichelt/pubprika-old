class Tag < ActiveRecord::Base
  strip_attributes

  has_many :recipe_tags
  has_many :recipes, through: :recipe_tags

  validates :name, presence: true
  validates :singularized, presence: true
  validates :referenced, presence: true

  OnlyBinaryFields = column_names.map {|cn| cn if columns_hash[cn].type == :binary}.compact
  OnlyDatetimeFields = column_names.map {|cn| cn if columns_hash[cn].type == :datetime}.compact
  OnlyIntegerFields = column_names.map {|cn| cn if columns_hash[cn].type == :integer}.compact
  OnlyDecimalFields = column_names.map {|cn| cn if columns_hash[cn].type == :decimal}.compact
  OnlyStringFields = column_names.map {|cn| cn if columns_hash[cn].type == :string}.compact
  OnlyTextFields = column_names.map {|cn| cn if columns_hash[cn].type == :text}.compact
  OnlyBooleanFields = column_names.map {|cn| cn if columns_hash[cn].type == :boolean}.compact
  SimpleFields = OnlyStringFields + OnlyTextFields + OnlyBooleanFields + OnlyIntegerFields
  ComplexFields = OnlyBinaryFields + OnlyDatetimeFields + OnlyDecimalFields
  IncludeHasMany = []
  IncludeHasManyReflections = IncludeHasMany
    .map {|hm| reflect_on_association(hm)}
    .map {|r| {
      table_name: r.plural_name,
      results_name: "#{r.plural_name.singularize}_results",
      model: r.plural_name.classify.constantize,
      order: "#{r.options.has_key?(:order) ? r.options[:order].split(", ").map {|o| "#{r.plural_name}.#{o}"}.join(", ") : ""}",
      fk: "#{r.options.has_key?(:foreign_key) ? r.options[:foreign_key] : "#{table_name.singularize}_id"}"}}
    .map {|h| Hashie::Mash.new(h)}
  IncludeBelongsTo = []
  IncludeBelongsToReflections = IncludeBelongsTo
    .map {|bt| reflect_on_association(bt)}
    .map {|r| {
      table_name: r.plural_name,
      results_name: "#{r.plural_name.singularize}_results",
      model: r.plural_name.classify.constantize,
      order: "#{r.options.has_key?(:order) ? r.options[:order].split(", ").map {|o| "#{r.plural_name}.#{o}"}.join(", ") : ""}",
      fk: "#{r.options[:foreign_key] || "#{r.plural_name.singularize}_id"}"}}
    .map {|h| Hashie::Mash.new(h)}

  scope :for_ar_pg, -> { select("
    #{SimpleFields.map {|f| "#{table_name}.#{f}"}*', '}
    #{OnlyBinaryFields.count > 0 ? ', ' : ''}
    #{OnlyBinaryFields.map {|f| "encode(#{table_name}.#{f}, 'base64') as #{f}"}*', '}
    #{OnlyDatetimeFields.count > 0 ? ', ' : ''}
    #{OnlyDatetimeFields.map {|f| "to_char(timezone('UTC', cast(#{table_name}.#{f} as timestamp(0))), 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') as #{f}"}*', '}
    #{OnlyDecimalFields.count > 0 ? ', ' : ''}
    #{OnlyDecimalFields.map {|f| "to_char(#{table_name}.#{f}, 'FM99999999999999999999.9999999999') as #{f}"}*', '}
    #{IncludeBelongsTo.count > 0 ? ', ' : ''}
    #{IncludeBelongsToReflections.map {|bt| "(SELECT row_to_json(#{bt.results_name}) from (#{bt.model.for_ar_pg.to_sql} where #{bt.table_name}.id = #{table_name}.#{bt.fk}) #{bt.results_name}) as #{bt.table_name.singularize}"}*', '}
    #{IncludeHasMany.count > 0 ? ', ' : ''}
    #{IncludeHasManyReflections.map {|hm| "(CASE WHEN (SELECT count(*) from #{hm.table_name} where #{hm.table_name}.#{hm.fk} = #{table_name}.id) = 0 THEN '[]' ELSE (SELECT json_agg(#{hm.results_name}) from (#{hm.model.for_ar_pg.to_sql} where #{hm.table_name}.#{hm.fk} = #{table_name}.id #{hm.order.length > 0 ? "ORDER BY #{hm.order}" : ""}) as #{hm.results_name}) END) as #{hm.table_name}"}*', '}") }
end
