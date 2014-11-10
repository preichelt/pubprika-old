class RecipesController < ApplicationController

  def index
    @recipes = get_recipes
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  private

  def get_recipes(per_page = nil)
    Recipe.all
      .page(params[:page] || 1)
      .per(per_page || params[:per_page] || Recipe.default_per_page)
  end
end
