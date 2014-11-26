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
    if !params[:q].blank?
      redirect_to recipes_path({q: params[:q]})
    else
      @recipe = Recipe.find(params[:id])
      respond_to do |format|
        format.html { render :show }
        format.json { render json: @recipe.as_json }
      end
    end
  end

  def random
    if !params[:t].blank?
      @recipe = Recipe.with_tags(params[:t]).sample
    else
      @recipe = Recipe.all.sample
    end
    redirect_to recipe_path(@recipe)
  end

  private

  def get_recipes(per_page = nil)
    query = Recipe
    if !params[:t].blank?
      query = query.with_tags(params[:t])
    end
    if !params[:q].blank?
      query = query.search_name_and_ingredients(params[:q])
        .page(params[:page] || 1)
        .per(per_page || params[:per_page] || Recipe.default_per_page)
    else
      query = query.all
        .order('name')
        .page(params[:page] || 1)
        .per(per_page || params[:per_page] || Recipe.default_per_page)
    end
    query
  end
end
