recipes = new Bloodhound(
  datumTokenizer: Bloodhound.tokenizers.obj.whitespace("value")
  queryTokenizer: Bloodhound.tokenizers.whitespace
  prefetch: "./recipes.json?page=2&per_page=200"
  remote: "./recipes.json?q=%QUERY"
)
recipes.initialize()
$(".typeahead").typeahead null,
  name: "recipes"
  displayKey: "value"
  source: recipes.ttAdapter()
