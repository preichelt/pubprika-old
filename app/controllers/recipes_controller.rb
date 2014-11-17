class RecipesController < ApplicationController

  def index
    @recipes = get_recipes
    respond_to do |format|
      format.html { render :index }
      format.json do
        render json: @recipes.as_json(only: [:name, :ingredients, :tags, :slug])
      end
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    if params.has_key?(:q) && params[:q] != ""
      redirect_to recipes_path({q: params[:q]})
    else
      respond_to do |format|
        format.html { render :show }
        format.json { render json: @recipe.as_json }
      end
    end
  end

  def random
    @recipe = Recipe.all.sample
    redirect_to recipe_path(@recipe)
  end

  private

  def get_recipes(per_page = nil)
    if params.has_key?(:q) && params[:q] != ""
      Recipe.search_name_and_ingredients(params[:q])
        .page(params[:page] || 1)
        .per(per_page || params[:per_page] || Recipe.default_per_page)
    else
      Recipe.all
        .order('name')
        .page(params[:page] || 1)
        .per(per_page || params[:per_page] || Recipe.default_per_page)
    end
  end
end
