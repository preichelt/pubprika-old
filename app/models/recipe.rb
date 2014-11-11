class Recipe < ActiveRecord::Base
  include PgSearch
  extend FriendlyId
  strip_attributes

  validates :name, presence: true

  pg_search_scope :search_by_name,
                  against: :name,
                  using: {tsearch: {prefix: true}}
  pg_search_scope :search_by_ingredient,
                  against: :ingredients,
                  using: {tsearch: {prefix: true}}
  pg_search_scope :search_by_tag,
                  against: :tags,
                  using: {tsearch: {prefix: true}}

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, :source],
      [:name, :source, :tags]
    ]
  end
end
