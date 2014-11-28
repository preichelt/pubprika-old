class RecipesController < ApplicationController

  def index
    @recipes = get_recipes
    respond_to do |format|
      format.html do
        tags_file = File.read("db/data/tags.json")
        tags_hash = JSON.parse(tags_file)
        @tags = tags_hash["tags"]
        if !params[:v].blank? && params[:v] == "grid"
          render :grid_index
        else
          render :index
        end
      end
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
      tags = params[:t].split(",").map {|t| ["BBQ", "4th of July"].include?(t) ? t : t.titleize}
      @recipe = Recipe.with_tags(tags).sample
    else
      @recipe = Recipe.all.sample
    end
    redirect_to recipe_path(@recipe)
  end

  private

  def get_recipes(per_page = nil)
    query = Recipe
    if !params[:t].blank?
      tags = params[:t].split(",").map {|t| ["BBQ", "4th of July"].include?(t) ? t : t.titleize}
      @current_tags = tags.map {|t| ["Christmas"].include?(t) ? "#{t}" : (t == "Cookies" ? "Cookie" : t == "Sauces/Spreads" ? "Sauce/Spread" : "#{t.singularize}")}.to_sentence + " Recipes"
      query = query.with_tags(tags)
    end
    if !params[:q].blank?
      query = query.search_name_and_ingredients(params[:q])
    else
      query = query.all
        .order('name')
    end
    query
      .page(params[:page] || 1)
      .per(per_page || params[:per_page] || Recipe.default_per_page)
  end
end
