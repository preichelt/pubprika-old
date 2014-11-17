# recipes = new Bloodhound(
#   datumTokenizer: Bloodhound.tokenizers.obj.whitespace("recipe")
#   queryTokenizer: Bloodhound.tokenizers.whitespace
#   prefetch: "/recipes.json?per_page=200"
#   remote: "/recipes.json?q=%QUERY"
# )
# recipes.initialize()
# $(".typeahead").typeahead null,
#   name: "recipes"
#   displayKey: "value"
#   source: recipes.ttAdapter()
