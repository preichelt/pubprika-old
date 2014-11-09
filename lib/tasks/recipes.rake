namespace :recipes do
  desc "Convert Paprika esported recipe html files to json using node cli tool."
  task :convert => :environment do
    system "./convert.js"
  end

  desc "Import recipes.json into db."
  task :import => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
    end
    file = File.read("db/data/recipes.json")
    data_hash = JSON.parse(file)
    total = data_hash["recipes"].count
    progress_bar = ProgressBar.create(title: "Recipes", starting_at: 0, total: total)
    recipes = []
    data_hash["recipes"].each do |recipe_data|
      recipe = Recipe.new(recipe_data)
      recipes << recipe
      progress_bar.increment
    end
    Recipe.import recipes
    Rails.logger.info("Finished importing recipes.")
  end
end
