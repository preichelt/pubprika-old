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
var tagsPath = destinationDir + "/tags.json";

scan(paprikaFilesDir, '.html', function(err, files){
  console.log("recipes.json and tags.json creation starting.");
  var filesWithoutIndex = _.without(files, paprikaFilesDir + "/index.html");
  var recipesHTML = _.map(filesWithoutIndex, function(file){
    var html = fs.readFileSync(file, "utf16le");
    return html;
  });

  var bar = new ProgressBar(':bar', {total: _.size(recipesHTML)});
  var recipes = [];
  var allTags = [];
  var slugId = 1;
  _.each(recipesHTML, function(html){
    var $ = cheerio.load(html);
    var name = $('h1.fn').text();

    var ingredients = [];
    $('.ingredients').find('li').each(function(i, el){
      ingredients[i] = $(this).text();
    });

    var directions = [];
    $('.instructions').find('p').each(function(i, el){
      directions[i] = $(this).text().replace(/(\r\n|\n|\r)/gm," ").replace(/\s+/g," ").trim();
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
    var sourceLastTwo = source.slice(-2);
    if(sourceLastTwo == "/#"){
      source = source.slice(0, -2);
    }

    var sourceBase = "";
    if(source != ""){
      sourceBase = source.replace("https://", "").replace("http://", "").replace("www.", "").split("/")[0]
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
      "source_base": sourceBase,
      "nutrition": nutrition,
      "slug_id": slugId
    };
    recipes.push(recipe);
    slugId += 1;
    bar.tick();
  });

  if(fs.existsSync(recipesPath)){
    fs.unlinkSync(recipesPath);
  }

  if(fs.existsSync(tagsPath)){
    fs.unlinkSync(tagsPath);
  }

  fs.writeFile(recipesPath, JSON.stringify({"recipes": recipes}, null, 2), {"encoding": "utf8"}, function(error){
    if(error) throw error;
    console.log("recipes.json has been built.");
  });


  uniqTags = _.uniq(allTags).sort()
  groupedTags = _.map(uniqTags, function(t){
    var tagGroup = {};
    tagGroup[t] = allTags.reduce(function(n, val){
      return n + (val === t);
    }, 0);
    return tagGroup;
  });

  fs.writeFile(tagsPath, JSON.stringify({"tags": groupedTags}, null, 2), {"encoding": "utf8"}, function(error){
    if(error) throw error;
    console.log("tags.json has been built.");
  });
});
