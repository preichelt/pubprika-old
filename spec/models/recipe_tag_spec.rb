require 'rails_helper'

RSpec.describe RecipeTag, type: :model do
  before(:each) { @recipe_tag = build(:recipe_tag) }

  subject { @recipe_tag }

  it "has the correct associations" do
    has_associations :recipe, :tag
  end

  it "validates the presence of required fields" do
    should_validate_presence :recipe_id, :tag_id
  end
end
