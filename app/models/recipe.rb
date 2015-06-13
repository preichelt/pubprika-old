class Recipe < ActiveRecord::Base
  extend FriendlyId
  extend ArPg
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

  scope :with_tags, lambda {|tag_ids| where("recipes.tag_ids && ARRAY[?]", [*tag_ids])}
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

  # Sample override
  # ArPg.module_eval do
  #   def blacklist_fields
  #     ["id"]
  #   end
  # end
end
