# frozen_string_literal: true

require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module EcAdmin
  class Application < Rails::Application
    config.load_defaults 8.0
    config.generators.system_tests = nil

    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :ja]
  end
end
