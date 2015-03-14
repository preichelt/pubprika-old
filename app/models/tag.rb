class Tag < ActiveRecord::Base
  extend ArPg

  strip_attributes

  validates :name, presence: true
  validates :singularized, presence: true
  validates :referenced, presence: true
end
