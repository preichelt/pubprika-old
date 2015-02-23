namespace :recipes do
  desc "Convert paprika esported recipe html files to json using node cli tool."
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
    progress_bar = ProgressBar.create(title: "Importing Recipes", starting_at: 0, total: total)
    recipes = []
    data_hash["recipes"].each do |recipe_data|
      recipe = Recipe.new(recipe_data)
      recipe.save!
      recipes << recipe
      progress_bar.increment
    end
    Rails.logger.info("Finished importing recipes. Determining common source bases.")
    total = recipes.count
    progress_bar = ProgressBar.create(title: "Determining", starting_at: 0, total: total)
    recipes.each do |recipe|
      if Recipe.where(source_base: recipe.source_base).count > 1
        recipe.update_attributes(common_source_base: true)
      end
      progress_bar.increment
    end
    Rails.logger.info("Finished determining common source bases.")
  end

  desc "Copy paprika exported recipe images to images/recipes directory."
  task :copy_images => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
    end
    recipes_dir = 'app/assets/images/recipes'
    Pathname.new(recipes_dir).children.each {|p| p.rmtree}
    FileUtils.cp_r 'paprika_files/images/.', recipes_dir
  end

  desc "Drop paprika files."
  task :drop_files => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
    end
    paprika_dir = 'paprika_files'
    Pathname.new(paprika_dir).children.each {|p| p.rmtree}
  end

  desc "Master task: covert -> import -> copy images -> precompile assets"
  task :master => :environment do
    if Rails.env == "development"
      Rails.logger = Logger.new(STDOUT)
    end
    system "bundle exec rake recipes:convert"
    system "bundle exec rake recipes:import"
    system "bundle exec rake recipes:copy_images"
    system "bundle exec rake assets:clobber"
    system "bundle exec rake assets:precompile RAILS_ENV=production"
  end
end
