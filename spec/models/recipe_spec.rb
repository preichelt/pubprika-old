require 'rails_helper'

RSpec.describe Recipe, type: :model do
  before(:each) { @recipe = build(:recipe) }

  subject { @recipe }

  it "validates the presence of required fields" do
    should_validate_presence :name
  end
end
