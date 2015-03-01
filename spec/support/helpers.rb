require 'support/helpers/model_spec_helpers'

RSpec.configure do |config|
  config.include ModelSpecHelpers, type: :model
  config.include ControllerSpecHelpers, type: :controller
end
