class RecipesController < ApplicationController

  def index
    @recipes = get_recipes
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def random
    @recipe = Recipe.all.sample
    redirect_to recipe_path(@recipe)
  end

  private

  def get_recipes(per_page = nil)
    Recipe.all
      .order('name')
      .page(params[:page] || 1)
      .per(per_page || params[:per_page] || Recipe.default_per_page)
  end
end
