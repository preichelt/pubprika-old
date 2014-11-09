class Recipe < ActiveRecord::Base
  strip_attributes

  validates :name, presence: true
end
