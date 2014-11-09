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
      t.string :source
      t.text :nutrition, array: true, default: []

      t.timestamps
    end
  end
end
