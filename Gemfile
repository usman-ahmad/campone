source 'https://rubygems.org'
ruby '~> 2.6.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

############
### BASE ###
############

# Loads environment variables from `.env`, should be on top of application's Gemfile
gem 'dotenv-rails' #, '~> 2.1.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0'

# Use postgresql as the database for Active Record
gem 'pg' #, '~> 0.18.4'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks' #, '~> 5.0.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# redis document database required for ActionCable
gem 'redis' #, '~> 3.3.3'

# Use Unicorn as the app server
gem 'unicorn' #, '~> 5.1.0'

# Puma is a simple, fast, threaded, and highly concurrent HTTP 1.1 server for Ruby/Rack applications.
gem 'puma' #, '~> 3.6.0'

# Moment.js is a lightweight javascript date library for parsing, manipulating, and formatting dates
gem 'momentjs-rails' #, '~> 2.11.1'

# Use fullcalendar to genrate calendar
gem 'fullcalendar-rails' #, '~> 2.4.0.1'

# Use public_activity, it provides easy activity tracking on Active Record
gem 'public_activity' #, '~> 1.5.0'

############################
### FRAMEWORK_EXTENSIONS ###
############################

# A tagging plugin for Rails applications that allows for custom tagging along dynamic contexts.
gem 'acts-as-taggable-on', '~> 4.0'

# front-end WYSIWYG editor
gem 'trumbowyg_rails', github: 'TikiTDO/trumbowyg_rails' #, '~> 2.1.0.3'

# FriendlyId is slugging and permalink solution for ActiveRecord
gem 'friendly_id', '~> 5.2'

# Pagination library
gem 'will_paginate', '~> 3.1.0'

#################
### FRONT_END ###
#################

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails' #, '~> 4.1.1'

# Use jquery as the JavaScript library
gem 'jquery-ui-sass-rails' #, '~> '

# Rails jQuery file uploads via standard Rails "remote: true" forms. http://os.alfajango.com/remotipart
gem 'remotipart' #, '~> 1.3.1'

# Use handlebars.js templates with the Rails asset pipeline
gem 'handlebars_assets' #, '~> 0.23.2'

# Using bootstrap
gem 'bootstrap-sass', '~> 3.3.5'

# gem for bootstrap social icons
gem 'bootstrap-social-rails' #, '~> 4.12.0'

# Use Font Awesome to get vector icons and social logos
gem 'font-awesome-sass' #, '~> 4.6.2'

###############
### UPLOADS ###
###############

# Use Paperclip, it is intended as an easy file attachment library for ActiveRecord.
gem 'paperclip' #, '~> 5.1.0'

# For generating thumbnails from videos
gem 'paperclip-av-transcoder' #, '~> 0.6.4'

###########
### API ###
###########

# Grape is a REST-like API framework for Ruby
gem 'grape' #, '~> 0.16.2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# for generating JSON response
gem 'active_model_serializers', '~> 0.10.0'

######################
### AUTHENTICATION ###
######################

# Use devise as authentication system
gem 'devise' #, '~> 4.5.0'

# improve device views
gem 'devise-bootstrap-views' #, '~> 0.0.8'

# invite users
gem 'devise_invitable' #, '~> 1.6.0'

# Use CanCan, authorization library for Ruby on Rails
gem 'cancancan', '~> 1.10'

###########################
### OMNIAUTH_STRATEGIES ###
###########################

# An abstract OAuth2 strategy for OmniAuth.
# got a redirect_uri_mismatch problem, It was caused by new version 1.4.0 of omniauth-oauth2 gem in below commit
# https://github.com/intridea/omniauth-oauth2/commit/26152673224aca5c3e918bcc83075dbb0659717f
# Use omniauth-oauth2 version 1.3.2 until issue is resolved
gem 'omniauth-oauth2', '~> 1.3.1'

# A Google OAuth2 strategy for OmniAuth 1.x
gem 'omniauth-google-oauth2' #, '~> 0.4.1'

# A JIRA OAuth 1.0a strategy for OmniAuth
gem 'omniauth-jira' #, '~> 0.2.0'

# OAuth 1.0 Strategy for Trello
gem 'omniauth-trello' #, '~> 0.0.4'

# OmniAuth strategy for Twitter
gem 'omniauth-twitter' #, '~> 1.2.1'

# Official OmniAuth strategy for Asana
gem 'omniauth-asana' #, '~> 0.0.2'

####################
### INTEGRATIONS ###
####################

# Used to interact with twitter account through twitter API
gem 'twitter' #, '~> 5.16.0'

# Used to interact with asana API
gem 'asana' #, '~> 0.5.0'

# Implementation of the Trello API for Ruby
gem 'ruby-trello' #, '~> 2.1.0'

# A Ruby gem for the JIRA REST API
gem 'jira-ruby', :require => 'jira-ruby' #, '~> 1.6'

# To interact with Pivotal Tracker API
gem 'tracker_api' #, '~> 1.4.1'

group :development do
  # Annotate Rails classes with schema and routes info.
  gem 'annotate' #, '~> 2.7.1'
  # Preview email in the default browser instead of sending it.
  gem 'letter_opener' #, '~> 1.4.1'
  # User better-error to inspect application error on browser
  gem 'better_errors' #, '~> 2.1.1'
  # Use rails-erd to generate ERD diagram of models
  gem 'rails-erd' #, '~> 1.4.7'
  # rails_best_practices is a code metric tool to check the quality of Rails code.
  gem 'rails_best_practices' #, '~> 1.17.0'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0', group: :doc

  ##################
  ### DEPLOYMENT ###
  ##################

  # Use Capistrano for automated deployments, capistranorb.com is Remote multi-server automation tool
  gem 'capistrano', '~> 3.8'
  # Upload, initialize and maintain configuration files for Capistrano 3.x outside(or inside) of SCM
  gem 'capistrano-upload-config', '~> 0.7'
  # rbenv support for Capistrano 3.x
  gem 'capistrano-rbenv', '~> 2.1'
  # Official Ruby on Rails specific tasks for Capistrano
  gem 'capistrano-rails', '~> 1.2'
  # Bundler support for Capistrano 3.x
  gem 'capistrano-bundler', '~> 1.2'
  # Puma integration for Capistrano
  gem 'capistrano3-puma', '~> 3.1'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug' #, '~> 9.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring' #, '~> 1.7.2'
  # testing framework for rails
  gem 'rspec-rails' #, '~> 3.5.1'
  # Simple one-liner tests for common Rails functionality
  gem 'shoulda-matchers', '~> 3.1'
  # used to create factories
  gem 'factory_girl_rails' #, '~> 4.7.0'
  # properly clean database after running rspecs
  gem 'database_cleaner' #, '~> 1.5.3'
  # Capybara helps you test web applications by simulating how a real user would interact with your app
  gem 'capybara' #, '~> 2.7.1'
  # Ruby bindings for WebDriver, selenium is a browser automation framework
  gem 'selenium-webdriver' #, '~> 2.53.4'
  # A PhantomJS driver for Capybara
  gem 'poltergeist' #, '~> 1.10.0'
end
