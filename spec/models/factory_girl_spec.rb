require 'rails_helper'

describe "FactoryGirl" do
  context "build" do
    FactoryGirl.factories.each do |factory|
      context ":#{factory.name} factory" do
        subject { build(factory.name) }

        it "is valid" do
          subject.valid?
        end
      end
    end
  end

  context "create" do
    FactoryGirl.factories.each do |factory|
      context ":#{factory.name} factory" do
        subject { create(factory.name) }

        it "is valid" do
          subject.valid?
        end
      end
    end
  end
end
