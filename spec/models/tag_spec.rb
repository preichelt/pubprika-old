require 'rails_helper'

RSpec.describe Tag, type: :model do
  before(:each) { @tag = build(:tag) }

  subject { @tag }

  it "validates the presence of required fields" do
    should_validate_presence :name, :singularized, :referenced
  end
end
