class Recipe < ActiveRecord::Base
  extend FriendlyId
  strip_attributes

  validates :name, presence: true

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      :name,
      [:name, :source],
      [:name, :source, :image]
    ]
  end
end
