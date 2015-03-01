class CreateRecipeTags < ActiveRecord::Migration
  def change
    create_table :recipe_tags do |t|
      t.integer :recipe_id, null: false
      t.integer :tag_id, null: false

      t.timestamps null: false
    end

    add_index :recipe_tags, :recipe_id
    add_index :recipe_tags, :tag_id
  end
end
