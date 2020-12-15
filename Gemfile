source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.3', '>= 6.0.3.3'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 4.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

gem 'devise', '~> 4.7', '>= 4.7.3'

# Authentication For use with client side single page apps
gem 'devise_token_auth', '~> 1.1', '>= 1.1.4'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Middleware that will make Rack-based apps CORS compatible
gem 'rack-cors', '~> 1.1', '>= 1.1.1'

# Adds methods to set and authenticate against one time passwords 2FA
gem 'active_model_otp', '~> 2.0', '>= 2.0.1'

# The official library for communicating with the Twilio REST API
gem 'twilio-ruby', '~> 5.40', '>= 5.40.3'

# Loads environment variables from `.env`.
gem 'dotenv', '~> 2.7', '>= 2.7.6'

# AR date validator
gem 'date_validator', '~> 0.10.0'

# Official AWS Ruby gem for Amazon Simple Storage Service (Amazon S3)
gem 'aws-sdk-s3', '~> 1.81', '>= 1.81.1', require: false

# ActiveRecord backend for Delayed::Job
gem 'delayed_job_active_record', '~> 4.1', '>= 4.1.4'

# A gem for calling the GoCardless Pro API
gem 'gocardless_pro', '~> 2.24'

# A simple HTTP and REST client for Ruby
gem 'rest-client', '~> 2.1'

# PgSearch builds Active Record named scopes that take advantage of PostgreSQL's full text search
gem 'pg_search', '~> 2.3', '>= 2.3.4'

gem 'daemons', '~> 1.3', '>= 1.3.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano', '~> 3.14', '>= 3.14.1'
  gem 'capistrano3-puma', '~> 5.0', '>= 5.0.2'
  gem 'capistrano-rails', '~> 1.6', '>= 1.6.1', require: false
  gem 'capistrano-bundler', '~> 2.0', '>= 2.0.1', require: false
  gem 'capistrano-rvm', '~> 0.1.2'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
