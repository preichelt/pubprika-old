require 'rails_helper'

RSpec.describe Recipe, type: :model do
  before(:each) { @recipe = build(:recipe) }

  subject { @recipe }

  it "has the correct associations" do
    has_associations :recipe_tags, :tags
  end

  it "validates the presence of required fields" do
    should_validate_presence :name
  end
end
