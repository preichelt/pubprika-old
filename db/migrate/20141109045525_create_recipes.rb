class CreateRecipes < ActiveRecord::Migration
  def change
    create_table :recipes do |t|
      t.text :name, null: false
      t.text :ingredients, array: true, default: []
      t.text :directions, array: true, default: []
      t.text :notes, array: true, default: []
      t.text :image
      t.text :tags, array: true, default: []
      t.text :prep_time
      t.text :cook_time
      t.text :amount
      t.text :source
      t.text :nutrition, array: true, default: []
      t.string :slug, unique: true

      t.timestamps
    end

    add_index :recipes, :slug, unique: true
  end
end
