class Recipe < ActiveRecord::Base
  extend FriendlyId
  include PgSearch

  strip_attributes

  validates :name, presence: true

  pg_search_scope :search_name_ingredients_and_source_base,
                  against: {
                    name: 'A',
                    ingredients: 'B',
                    source_base: 'C'
                  },
                  ignoring: :accents,
                  using: {tsearch: {prefix: true}}

  pg_search_scope :search_source_base,
                  against: :source_base,
                  using: {tsearch: {prefix: true}}

  scope :with_tags, lambda {|tag_ids| where("recipes.tag_ids && ARRAY[?]", [*tag_ids]) }
  scope :sorted_by, lambda {|sort_option| order("recipes.#{sort_option}")}

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, :slug_id]
    ]
  end

  def self.default_per_page
    52
  end

  def tags
    Tag.where{|t| t.id.in(tag_ids)}
  end

  BlacklistFields = []
  BinaryFields = column_names.map {|cn| cn if columns_hash[cn].type == :binary}.compact.reject {|f| BlacklistFields.include?(f)}
  DatetimeFields = column_names.map {|cn| cn if columns_hash[cn].type == :datetime}.compact.reject {|f| BlacklistFields.include?(f)}
  IntegerFields = column_names.map {|cn| cn if columns_hash[cn].type == :integer}.compact.reject {|f| BlacklistFields.include?(f)}
  DecimalFields = column_names.map {|cn| cn if columns_hash[cn].type == :decimal}.compact.reject {|f| BlacklistFields.include?(f)}
  StringFields = column_names.map {|cn| cn if columns_hash[cn].type == :string}.compact.reject {|f| BlacklistFields.include?(f)}
  TextFields = column_names.map {|cn| cn if columns_hash[cn].type == :text}.compact.reject {|f| BlacklistFields.include?(f)}
  BooleanFields = column_names.map {|cn| cn if columns_hash[cn].type == :boolean}.compact.reject {|f| BlacklistFields.include?(f)}
  SimpleFields = StringFields + TextFields + BooleanFields + IntegerFields
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
    #{BinaryFields.count > 0 ? ', ' : ''}
    #{BinaryFields.map {|f| "encode(#{table_name}.#{f}, 'base64') as #{f}"}*', '}
    #{DatetimeFields.count > 0 ? ', ' : ''}
    #{DatetimeFields.map {|f| "to_char(timezone('UTC', cast(#{table_name}.#{f} as timestamp(0))), 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') as #{f}"}*', '}
    #{DecimalFields.count > 0 ? ', ' : ''}
    #{DecimalFields.map {|f| "to_char(#{table_name}.#{f}, 'FM99999999999999999999.9999999999') as #{f}"}*', '}
    #{IncludeBelongsTo.count > 0 ? ', ' : ''}
    #{IncludeBelongsToReflections.map {|bt| "(SELECT row_to_json(#{bt.results_name}) from (#{bt.model.for_ar_pg.to_sql} where #{bt.table_name}.id = #{table_name}.#{bt.fk}) #{bt.results_name}) as #{bt.table_name.singularize}"}*', '}
    #{IncludeHasMany.count > 0 ? ', ' : ''}
    #{IncludeHasManyReflections.map {|hm| "(CASE WHEN (SELECT count(*) from #{hm.table_name} where #{hm.table_name}.#{hm.fk} = #{table_name}.id) = 0 THEN '[]' ELSE (SELECT json_agg(#{hm.results_name}) from (#{hm.model.for_ar_pg.to_sql} where #{hm.table_name}.#{hm.fk} = #{table_name}.id #{hm.order.length > 0 ? "ORDER BY #{hm.order}" : ""}) as #{hm.results_name}) END) as #{hm.table_name}"}*', '}") }
end
