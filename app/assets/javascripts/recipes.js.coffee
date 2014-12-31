ready = ->
  recipes = new Bloodhound(
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace("value")
    queryTokenizer: Bloodhound.tokenizers.whitespace
    remote: {
      url: "/recipes.json?per_page=5&q=%QUERY"
      filter: (data) ->
        data.recipes
    }
  )
  recipes.initialize()
  $(".typeahead").typeahead null,
    name: "q"
    displayKey: "name"
    source: recipes.ttAdapter()

  $(".note-content").each (i) ->
    $(this).html(urlize($(this).html(), {nofollow: true, autoescape: true}))

$(document).ready ready
$(document).on "page:load", ready
