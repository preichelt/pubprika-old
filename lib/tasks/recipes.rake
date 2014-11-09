namespace :recipes do
  desc "Convert Paprika esported recipe html files to json using node cli tool."
  task :convert => :environment do
    system "./convert.js"
  end

  desc "Import recipes.json into db."
  task :import => :environment do
    file = File.read("db/data/recipes.json")
    data_hash = JSON.parse(file)
    total = data_hash["recipes"].count
    recipe_number = 1
    recipes = []
    data_hash["recipes"].each do |recipe_data|
      recipe = Recipe.new(recipe_data)
      recipes << recipe
      Rails.logger.info("Initialized recipe # #{recipe_number}/#{total}.")
      recipe_number += 1
    end
    Recipe.import recipes
    Rails.logger.info("Finished importing recipes.")
  end
end
