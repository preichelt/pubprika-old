class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.text :ingredients, array: true, default: []
      t.text :directions, array: true, default: []
      t.text :notes, array: true, default: []
      t.string :image
      t.text :tags, array: true, default: []
      t.string :prep_time
      t.string :cook_time
      t.string :amount
      t.text :source
      t.string :source_base
      t.text :nutrition, array: true, default: []
      t.string :slug, unique: true
      t.integer :slug_id, unique: true

      t.timestamps
    end

    add_index :recipes, :slug, unique: true
    add_index :recipes, :slug_id, unique: true
    add_index :recipes, :name
    add_index :recipes, :ingredients
    add_index :recipes, :tags
    add_index :recipes, :source
  end
end
