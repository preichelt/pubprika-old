namespace :recipes do
  desc "Convert Paprika esported recipe html files to json using node cli tool."
  task :convert => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
      system "./convert.js"
    else
      Rails.logger.warn("This task can only be used in a dev environment.")
    end
  end

  desc "Import recipes.json into db."
  task :import => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
    end
    Rails.logger.info("Removing existing recipes from db.")
    Recipe.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Recipe.table_name)
    Rails.logger.info("Finished removing existing recipes.")
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

  desc "Copy Paprika exported recipe images to images/recipes directory."
  task :copy_images => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
    end
    FileUtils.cp_r 'paprika_files/images/.', 'app/assets/images/recipes'
  end
end
