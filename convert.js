#!/usr/bin/env node
var fs = require('fs');
var cheerio = require('cheerio');
var async = require('async');
var _ = require('underscore');
var ProgressBar = require('progress');

var scan = function(dir, suffix, callback){
  fs.readdir(dir, function(err, files){
    var returnFiles = [];
    async.each(files, function(file, next){
      var filePath = dir + '/' + file;
      fs.stat(filePath, function(err, stat){
        if (err) {
          return next(err);
        }
        if (stat.isDirectory()){
          scan(filePath, suffix, function(err, results){
            if (err) {
              return next(err);
            }
            returnFiles = returnFiles.concat(results);
            next();
          })
        }
        else if (stat.isFile()){
          if (file.indexOf(suffix, file.length - suffix.length) !== -1){
            returnFiles.push(filePath);
          }
          next();
        }
      });
    }, function(err){
      callback(err, returnFiles);
    });
  });
};

var paprikaFilesDir = 'paprika_files';
var destinationDir = 'db/data';
var recipesPath = destinationDir + "/recipes.json";

scan(paprikaFilesDir, '.html', function(err, files){
  console.log("recipes.json creation starting.");
  var filesWithoutIndex = _.without(files, paprikaFilesDir + "/index.html");
  var recipeNames = [];
  var recipesHTML = _.map(filesWithoutIndex, function(file){
    var html = fs.readFileSync(file, "utf16le");
    var $ = cheerio.load(html);
    var name = $('h1.fn').text();
    var source = "";
    if($('.source').length){
      source = $('.source').attr('href');
    }
    name = name + source;
    recipeNames.push(name);
    return html;
  });

  var bar = new ProgressBar(':bar', {total: _.size(recipesHTML)});
  var recipes = [];
  var allTags = [];
  _.each(recipesHTML, function(html){
    var $ = cheerio.load(html);
    var name = $('h1.fn').text();

    var ingredients = [];
    $('.ingredients').find('li').each(function(i, el){
      ingredients[i] = $(this).text();
    });

    var directions = [];
    $('.instructions').find('p').each(function(i, el){
      directions[i] = $(this).text();
    });

    var notes = [];
    $('.notes').find('p').each(function(i, el){
      notes[i] = $(this).text();
    });

    var image = "";
    if($('.photo').length){
      image = $('.photo').attr('src').replace(/images\//g, '');
    }

    var tags = [];
    if($('.categories').length){
      tags = $('.categories').text().split(', ');
    }
    allTags = allTags.concat(tags);

    var prepTime = "";
    if($('.prepTime').length){
      prepTime = $('.prepTime').text();
    }

    var cookTime = "";
    if($('.cookTime').length){
      cookTime = $('.cookTime').text();
    }

    var amount = "";
    if($('.yield').length){
      amount = $('.yield').text();
    }

    var source = "";
    if($('.source').length){
      source = $('.source').attr('href');
    }

    var nutrition = [];
    $('.nutrition').find('p').each(function(i, el){
      nutrition[i] = $(this).text();
    });

    var recipe = {
      "name": name,
      "ingredients": ingredients,
      "directions": directions,
      "notes": notes,
      "image": image,
      "tags": tags,
      "prep_time": prepTime,
      "cook_time": cookTime,
      "amount": amount,
      "source": source,
      "nutrition": nutrition
    };
    recipes.push(recipe);
    bar.tick();
  });

  if(fs.existsSync(recipesPath)){
    fs.unlinkSync(recipesPath);
  }

  fs.writeFile(recipesPath, JSON.stringify({"recipes": recipes, "tags": _.uniq(allTags)}, null, 2), {"encoding": "utf8"}, function(error){
    if(error) throw error;
    console.log("recipes.json has been built.");
  });
});
