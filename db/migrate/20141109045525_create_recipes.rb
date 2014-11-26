class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.string :ingredients, array: true, default: []
      t.text :directions, array: true, default: []
      t.text :notes, array: true, default: []
      t.string :image
      t.string :tags, array: true, default: []
      t.string :prep_time
      t.string :cook_time
      t.string :amount
      t.string :source
      t.text :nutrition, array: true, default: []
      t.string :slug, unique: true

      t.timestamps
    end

    add_index :recipes, :slug, unique: true
  end
end
