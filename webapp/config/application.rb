require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Webapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.pdf_storage = '../pdfs'

    config.weaviate = Langchain::Vectorsearch::Weaviate.new(
      url: 'http://127.0.0.1:8080',
      api_key: '',
      index_name: "PDF1",
      llm: Langchain::LLM::OpenAI.new(
        api_key: Rails.application.credentials.openai_api_key,
        default_options: {
          completion_model_name: 'gpt-4-1106-preview',
          chat_completion_model_name: 'gpt-4-1106-preview'
        }
      )
    )
  end
end
