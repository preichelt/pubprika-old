module ControllerSpecHelpers
  def parsed_json
    JSON.parse(response.body)
  end
end
