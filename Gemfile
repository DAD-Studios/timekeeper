source "https://rubygems.org"

gem "rails", "~> 8.1.1"

# The modern asset pipeline for Rails
gem "propshaft"

# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"

# Use the Puma web server
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps
gem "importmap-rails"

# Hotwire's SPA-like page accelerator
gem "turbo-rails"

# Hotwire's modest JavaScript framework
gem "stimulus-rails"

# Build JSON APIs with ease
gem "jbuilder"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mri windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "rspec-rails", "~> 6.0"
  gem "shoulda-matchers", "~> 5.0"
  gem "factory_bot_rails", "~> 6.0"
  gem 'brakeman'
  gem 'rubocop-rails-omakase'
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "rails-controller-testing"
end

gem "bootstrap"
gem "dartsass-rails"
gem "kaminari"
gem "prawn"
gem "prawn-table"

gem "image_processing", "~> 1.14"

gem "lexxy", "~> 0.1.10.beta"


