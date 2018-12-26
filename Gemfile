source 'https://rubygems.org'
ruby '~> 2.6.0'

# Loads environment variables from `.env`, should be on top of application's Gemfile
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'

# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Rails jQuery file uploads via standard Rails "remote: true" forms. http://os.alfajango.com/remotipart
gem 'remotipart'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# Using bootstrap
gem 'bootstrap-sass', '~> 3.3.5'
# Use device to login asignup and authentication
gem 'devise'
# A tagging plugin for Rails applications that allows for custom tagging along dynamic contexts.
gem 'acts-as-taggable-on', '~> 4.0'
# improve device views
gem 'devise-bootstrap-views'
# invite users
gem 'devise_invitable'
# Use Paperclip, it is intended as an easy file attachment library for ActiveRecord.
gem 'paperclip'
# For generating thumbnails from videos
gem 'paperclip-av-transcoder'
# Moment.js is a lightweight javascript date library for parsing, manipulating, and formatting dates
gem 'momentjs-rails'
# Use fullcalendar to genrate calendar
gem 'fullcalendar-rails'
# Use public_activity, it provides easy activity tracking on Active Record
gem 'public_activity'
# Use CanCan, authorization library for Ruby on Rails
gem 'cancancan', '~> 1.10'
gem 'font-awesome-sass'
#gem for API
gem 'grape'
#gem for WYSIWYG
gem 'trumbowyg_rails', github: 'TikiTDO/trumbowyg_rails'

# To create slugs
# facing an issue with custom slug_column see https://github.com/norman/friendly_id/issues/765
gem 'friendly_id', github: 'norman/friendly_id'

# gem for bootstrap social icons
gem 'bootstrap-social-rails'
gem 'jquery-ui-sass-rails'

# Pagination library
gem 'will_paginate', '~> 3.1.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
# Use Unicorn as the app server
gem 'unicorn'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# for generating JSON response
gem 'active_model_serializers', '~> 0.10.0'

gem 'handlebars_assets'

group :development do
  # Annotate Rails classes with schema and routes info.
  gem 'annotate'
  # Preview email in the default browser instead of sending it.
  gem 'letter_opener'
  # User better-error to inspect application error on browser
  gem 'better_errors'
  # Use rails-erd to generate ERD diagram of models
  gem 'rails-erd'
  # rails_best_practices is a code metric tool to check the quality of Rails code.
  gem 'rails_best_practices'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Use Capistrano for automated deployments, capistranorb.com is Remote multi-server automation tool
  gem 'capistrano', require: false
  # Upload, initialize and maintain configuration files for Capistrano 3.x outside(or inside) of SCM
  gem 'capistrano-upload-config', require: false
  # RVM support for Capistrano 3.x
  gem 'capistrano-rvm', require: false
  # Official Ruby on Rails specific tasks for Capistrano
  gem 'capistrano-rails', require: false
  # Bundler support for Capistrano 3.x
  gem 'capistrano-bundler', require: false
  # Puma integration for Capistrano
  gem 'capistrano3-puma', github: 'seuros/capistrano-puma'
end

group :test do
  gem 'shoulda-matchers', '~> 3.1'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'rspec-rails'
  # used to create factories
  gem 'factory_girl_rails'
  # properly clean database after running rspecs
  gem 'database_cleaner'
  # Capybara helps you test web applications by simulating how a real user would interact with your app
  gem 'capybara'
  # capybara driver
  gem 'selenium-webdriver'
  gem 'poltergeist'
end

# got a redirect_uri_mismatch problem, It was caused by new version 1.4.0 of omniauth-oauth2 gem in below commit
# https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f
# Use omniauth-oauth2 version 1.3.2 until issue is resolved
gem 'omniauth-oauth2', '~> 1.3.1'
gem 'omniauth-google-oauth2'
gem 'omniauth-jira'
gem 'omniauth-trello'

# User for authentication
gem 'omniauth-twitter'
gem 'omniauth-asana'

# Used to interact with twitter account through twitter API
gem 'twitter'

# Used to interact with asana API
gem 'asana'
# gem 'jira-ruby', github: 'sumoheavy/jira-ruby', :branch => 'master'
gem 'ruby-trello'
gem 'jira-ruby', github: 'zuf/jira-ruby', branch: 'master'

# To interact with Pivotal Tracker API
gem 'tracker_api'

# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications.
gem 'puma'

# Required for ActionCable
gem 'redis'
