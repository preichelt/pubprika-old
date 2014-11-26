class Recipe < ActiveRecord::Base
  extend FriendlyId
  include PgSearch

  strip_attributes

  validates :name, presence: true

  pg_search_scope :search_by_name,
                  against: :name,
                  ignoring: :accents,
                  using: {tsearch: {prefix: true}}

  pg_search_scope :search_by_ingredient,
                  against: :ingredients,
                  ignoring: :accents,
                  using: {tsearch: {prefix: true}}

  pg_search_scope :search_by_tag,
                  against: :tags,
                  ignoring: :accents,
                  using: {tsearch: {prefix: true}}

  pg_search_scope :search_name_and_ingredients,
                  against: {
                    name: 'A',
                    ingredients: 'B'
                  },
                  ignoring: :accents,
                  using: {tsearch: {prefix: true}}

  scope :with_tags, lambda { |tags| where("recipes.tags && ARRAY[?]", [*tags]) }

  scope :sorted_by, lambda { |sort_option| order("recipes.#{sort_option}") }

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, :source],
      [:name, :source, :tags]
    ]
  end
end
