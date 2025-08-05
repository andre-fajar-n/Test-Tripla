require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module TestTripla
  class Application < Rails::Application
    config.load_defaults 7.2
    config.api_only = true

    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any, methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
      end
    end
  end
end
