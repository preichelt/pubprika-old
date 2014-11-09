require 'rails_helper'

describe RecipesController do
  describe "routing" do
    it "routes to #index" do
      expect(get("/recipes")).to route_to("recipes#index")
    end

    it "routes to #show" do
      expect(get("/recipes/1")).to route_to("recipes#show", id: "1")
    end
  end
end
