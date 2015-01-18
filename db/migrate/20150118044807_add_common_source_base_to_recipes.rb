class AddCommonSourceBaseToRecipes < ActiveRecord::Migration
  def up
    add_column :recipes, :common_source_base, :boolean, default: false
  end

  def down
    remove_column :recipes, :common_source_base
  end
end
