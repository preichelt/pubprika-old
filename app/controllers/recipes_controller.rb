class RecipesController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        rp = recipe_params
        recipes = []
        if !rp[:q].blank?
          recipes = Recipe.where(name: rp[:q])
        end
        if recipes.length == 1 && redirect?
          redirect_to recipe_path(recipes.first)
        else
          @recipes = get_recipes
          if @recipes.length == 1 && redirect?
            redirect_to recipe_path(@recipes.first)
          else
            @tags = Tag.all
            render :index
          end
        end
      end
      format.json do
        @recipes = Recipe.ar_pg_wrap(get_recipes.for_ar_pg, "recipes")
        render json: Recipe.ar_pg_package([@recipes])
      end
    end
  end

  def show
    rp = recipe_params
    if !rp[:q].blank?
      redirect_to recipes_path({q: rp[:q]})
    else
      respond_to do |format|
        format.html do
          @recipe = Recipe.find(rp[:id])
          @recipe_tags = @recipe.tags
          @tags = Tag.all
          render :show
        end
        format.json do
          render json: Recipe.ar_pg_wrap_find(Recipe.where(id: rp[:id]).limit(1).for_ar_pg)
        end
      end
    end
  end

  def random
    @recipe = get_random_recipe
    redirect_to recipe_path(@recipe)
  end

  private

  def recipe_params
    params.permit(
      :id,
      :q,
      :r,
      :s,
      :t,
      :v,
      :per_page,
      :page
    )
  end

  def get_recipes(per_page = nil)
    rp = recipe_params
    query = Recipe
    if !rp[:t].blank?
      tags = rp[:t]
        .split(",")
        .map {|t| ["BBQ", "4th of July"].include?(t) ? t : t.titleize}
        .map {|t| Tag.find_by_name(t)}
        .compact
      @current_tags = tags.map {|t| t.singularized}.to_sentence + " Recipes"
      query = query.with_tags(tags.map {|t| t.id})
    end
    if !rp[:q].blank?
      query = query.search_name_ingredients_and_source_base(rp[:q])
    elsif !rp[:s].blank?
      query = query.search_source_base(rp[:s])
    else
      query = query.all
        .order('name')
    end
    query
      .page(rp[:page] || 1)
      .per(per_page || ENV['RECIPES_PER_PAGE'] || rp[:per_page] || Recipe.default_per_page)
  end

  def get_random_recipe
    rp = recipe_params
    if !rp[:t].blank?
      tags = rp[:t]
        .split(",")
        .map {|t| ["BBQ", "4th of July"].include?(t) ? t : t.titleize}
        .map {|t| Tag.find_by_name(t)}
        .compact
      Recipe.with_tags(tags.map {|t| t.id}).offset(rand(Recipe.with_tags(tags.map {|t| t.id}).count)).first
    else
      Recipe.offset(rand(Recipe.count)).first
    end
  end

  def redirect?
    rp = recipe_params
    rp.has_key?(:r) ? (rp[:r].downcase == "no" ? false : true) : true
  end
end
