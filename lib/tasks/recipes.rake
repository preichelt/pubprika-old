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

    Rails.logger.info("Removing exisiting recipe tags from db.")
    RecipeTag.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(RecipeTag.table_name)
    Rails.logger.info("Finished removing exisiting recipe tags.")
    Rails.logger.info("Removing existing recipes from db.")
    Recipe.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Recipe.table_name)
    Rails.logger.info("Finished removing existing recipes.")
    Rails.logger.info("Removing existing tags from db.")
    Tag.delete_all
    ActiveRecord::Base.connection.reset_pk_sequence!(Tag.table_name)
    Rails.logger.info("Finished removing existing tags.")

    tag_file = File.read("db/data/tags.json")
    tag_data_hash = JSON.parse(tag_file)
    total = tag_data_hash["tags"].count
    progress_bar = ProgressBar.create(title: "Importing Tags", starting_at: 0, total: total)
    tag_data_hash["tags"].each do |tag_data|
      tag = Tag.new(tag_data)
      if ["Christmas"].include?(tag.name)
        tag.singularized = tag.name
      elsif ["Cookies"].include?(tag.name)
        tag.singularized = tag.name[0..-2]
      else
        singularized = tag.name.split(" & ").map {|t| t.singularize}.join(" & ")
        tag.singularized = singularized
      end
      tag.save!
      progress_bar.increment
    end
    Rails.logger.info("Finished importing tags.")

    file = File.read("db/data/recipes.json")
    data_hash = JSON.parse(file)
    total = data_hash["recipes"].count
    progress_bar = ProgressBar.create(title: "Importing Recipes", starting_at: 0, total: total)
    recipes = []
    data_hash["recipes"].each do |recipe_data|
      tags = recipe_data["tags"]
      recipe_data.delete("tags")
      recipe = Recipe.new(recipe_data)
      recipe.save!
      recipes << recipe

      tags.each do |t|
        tag = Tag.find_by_name(t)
        recipe_tag = RecipeTag.create!(recipe_id: recipe.id, tag_id: tag.id)
      end

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
