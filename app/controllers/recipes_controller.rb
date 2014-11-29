class RecipesController < ApplicationController

  def index
    @recipes = get_recipes
    respond_to do |format|
      format.html do
        tags_file = File.read("db/data/tags.json")
        tags_hash = JSON.parse(tags_file)
        @tags = tags_hash["tags"]
        render :index
      end
      format.json do
        render json: @recipes.as_json(only: [:name, :ingredients, :tags, :slug])
      end
    end
  end

  def show
    rp = recipe_params
    if !rp[:q].blank?
      redirect_to recipes_path({q: rp[:q]})
    else
      @recipe = Recipe.find(rp[:id])
      respond_to do |format|
        format.html { render :show }
        format.json { render json: @recipe.as_json }
      end
    end
  end

  def random
    @recipe = get_recipes(Recipe.all.count).sample
    redirect_to recipe_path(@recipe)
  end

  private

  def recipe_params
    params.permit(
      :id,
      :t,
      :q,
      :v,
      :s,
      :per_page,
      :page
    )
  end

  def get_recipes(per_page = nil)
    rp = recipe_params
    query = Recipe
    if !rp[:t].blank?
      tags = rp[:t].split(",").map {|t| ["BBQ", "4th of July"].include?(t) ? t : t.titleize}
      @current_tags = tags.map {|t| ["Christmas"].include?(t) ? "#{t}" : (t == "Cookies" ? "Cookie" : t == "Sauces/Spreads" ? "Sauce/Spread" : "#{t.singularize}")}.to_sentence + " Recipes"
      query = query.with_tags(tags)
    end
    if !rp[:q].blank?
      query = query.search_name_and_ingredients(rp[:q])
    elsif !rp[:s].blank?
      query = query.search_source_base(rp[:s])
    else
      query = query.all
        .order('name')
    end
    query
      .page(rp[:page] || 1)
      .per(per_page || rp[:per_page] || Recipe.default_per_page)
  end
end
