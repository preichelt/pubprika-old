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

  scope :with_tags, lambda { |tags| where("recipes.tags && ARRAY[?]", [*tags]) }
  scope :sorted_by, lambda { |sort_option| order("recipes.#{sort_option}") }

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

  # would be better to determine this during data import, rather than each time
  def other_source_base_recipes?
    if Recipe.search_source_base(self.source_base).length > 1
      true
    else
      false
    end
  end
end
