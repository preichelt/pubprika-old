ready = ->
  $("[data-toggle=\"tooltip\"]").tooltip()

  recipes = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace("value")
    queryTokenizer: Bloodhound.tokenizers.whitespace
    prefetch: "/recipes.json"
    remote: "/recipes.json?q=%QUERY"
  )
  recipes.initialize()
  $(".typeahead").typeahead null,
    name: "q"
    displayKey: "name"
    source: recipes.ttAdapter()

$(document).ready ready
$(document).on "page:load", ready
