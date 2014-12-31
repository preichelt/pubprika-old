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
            tags_file = File.read("db/data/tags.json")
            tags_hash = JSON.parse(tags_file)
            @tags = tags_hash["tags"]
            render :index
          end
        end
      end
      format.json do
        render json: ArPgJson.wrap(get_recipes.select(["id", "name", "slug"]), "recipes")["recipes"]
      end
    end
  end

  def show
    rp = recipe_params
    if !rp[:q].blank?
      redirect_to recipes_path({q: rp[:q]})
    else
      # separate into format specific calls, find for html, where for json so PgJson.wrap can be used
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
      tags = rp[:t].split(",").map {|t| ["BBQ", "4th of July"].include?(t) ? t : t.titleize}
      @current_tags = tags.map {|t| ["Christmas"].include?(t) ? "#{t}" :
        (t == "Cookies" ? "Cookie" : (t == "Sauces & Spreads" ? "Sauce & Spread" :
        (t == "Breads & Doughs" ? "Bread & Dough" : (t == "Desserts & Sweets" ? "Dessert & Sweet" :
        (t == "Frostings & Glazes" ? "Frosting & Glaze" : (t == "Muffins & Cupcakes" ? "Muffin & Cupcake" :
        (t == "Salads & Dressings" ? "Salad & Dressing" : (t == "Sandwiches & Wraps" ? "Sandwich & Wrap" :
        (t == "Soups & Stews" ? "Soup & Stew" : "#{t.singularize}")))))))))}.to_sentence + " Recipes"
      query = query.with_tags(tags)
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

  def redirect?
    rp = recipe_params
    rp.has_key?(:r) ? (rp[:r].downcase == "no" ? false : true) : true
  end
end
