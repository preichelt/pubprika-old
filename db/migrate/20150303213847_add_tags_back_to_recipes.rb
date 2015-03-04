class AddTagsBackToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :tag_ids, :integer, array: true, default: []
  end
end
