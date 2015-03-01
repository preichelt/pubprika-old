class RemoveTagsFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :tags
  end
end
