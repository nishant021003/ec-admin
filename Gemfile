# frozen_string_literal: true

source "https://rubygems.org"

ruby "~> 3.4.6"

gem "rails", "~> 8.0"
gem "pg", "~> 1.5", force_ruby_platform: true
gem "bcrypt", "~> 3.1"
gem "rolify", "~> 6.0"
gem "kaminari", "~> 1.2"
gem "paper_trail", "~> 15.0"
gem "image_processing", "~> 1.2"

gem "bootsnap", "~> 1.18", require: false
gem "puma", "~> 6.0"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "rspec-rails", "~> 7.0"
  gem "factory_bot_rails", "~> 6.4"
  gem "capybara", "~> 3.40"
  gem "webdrivers", "~> 5.0"
  gem "rubocop-rails-omakase", "~> 1.0"
  gem "rubocop-rspec", "~> 3.0"
  gem "brakeman", "~> 6.0"
  gem "rails_best_practices", "~> 1.22"
  gem "simplecov", "~> 0.22", require: false
  gem "overcommit", "~> 0.65", require: false
end

group :development do
  gem "web-console", "~> 4.2"
end
