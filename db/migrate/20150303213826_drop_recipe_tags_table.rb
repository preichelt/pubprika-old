class DropRecipeTagsTable < ActiveRecord::Migration
  def change
    drop_table :recipe_tags
  end
end
