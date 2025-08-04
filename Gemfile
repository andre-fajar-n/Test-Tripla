source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.5"

gem "rails", "~> 7.2.1"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "bootsnap", ">= 1.4.4", require: false
gem "rack-cors"
gem "dotenv-rails"

# Assets
gem "sprockets-rails"
gem "importmap-rails"

# API Documentation
gem "rswag"
gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  gem "debug", platforms: [:mri, :mingw, :x64_mingw]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "rswag-specs"
end

group :development do
  gem "listen", "~> 3.3"
  gem "spring"
end
