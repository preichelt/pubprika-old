require 'rails_helper'

RSpec.describe RecipesController do
  let!(:recipe1) { create(:recipe) }

  context "GET index" do
    context "html" do
      it "assigns @recipes" do
        get :index
        expect(assigns(:recipes)).to eq([recipe1])
      end

      context "1 recipe" do
        it "redirects to recipe path" do
          get :index
          expect(response).to redirect_to recipe_path(recipe1)
        end
      end

      context "more than 1 recipe" do
        let!(:recipe2) { create(:recipe) }

        it "renders the index template" do
          get :index
          expect(response).to render_template("index")
        end

        it "assigns @tags" do
          get :index
          recipe1.tags.each {|t| expect(assigns(:tags)).to include(t)}
          recipe2.tags.each {|t| expect(assigns(:tags)).to include(t)}
        end
      end
    end

    context "json" do
      it "returns json structure" do
        get :index, format: :json
        body = parsed_json
        expect(body.has_key?("recipes")).to eq(true)
        expect(body["recipes"].first["id"]).to eq(recipe1.id)
        expect(body["recipes"].first["name"]).to eq(recipe1.name)
      end
    end
  end
end
