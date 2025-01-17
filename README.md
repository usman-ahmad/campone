# NimbleIn
The next generation complete agile Project Management software.

These instructions will get you a copy of the project up and running on your 
local machine for development and testing purposes. See deployment for notes 
on how to deploy the project on a live system.


## Prerequisites (Ubuntu flavoured)

NimbleIn is built on Ruby 2, Rails 5, and uses PostgreSQL 9.2

##### Install GIT

    sudo apt-get install git

##### Install PostgreSQL

    sudo apt-get update
    sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev

##### Install RVM

    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    \curl -sSL https://get.rvm.io | bash

##### Install Nodejs with NVM 

    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
    nvm install node

##### Install libxml for Nokogiri

    sudo apt-get install libxslt-dev libxml2-dev

##### Install Image-Magick and FFMPEG for paperclip attachments

    sudo apt install imagemagick ffmpeg

##### Install redis for ActionCable

    sudo apt-get install redis-server

## Setup / Installing

##### Clone Project

    git clone git@gitlab.com:teknuk/camp_one.git
    or
    git clone git@bitbucket.org:teknuk/camp_one.git

##### Install Ruby and Bundler

Once you change directory to camp_one you will be prompted with 
> ruby-2.X.Y is not installed.
> To install do: 'rvm install ruby-2.X.Y'

So kindly install that ruby by using proper `X` and `Y` for 
`rvm install ruby-2.X.Y`. Now do `cd .` so that RVM creates the gemset for you 
and starts using that gemset. Now install bundler for this new gemset

    gem install bundler

##### Install Gems using Bundler

    bin/bundle install

##### Configure Database and DotEnv for Development Environment 

    cp config/database.yml.sample config/database.yml
    cp .env.sample .env

and edit newly created `database.yml` and `.env` with you credentials.

##### Create and Migrate Database

    bin/rails db:create
    bin/rails db:migrate

to OPTIONALLY initialize database with seed data run `bin/rails db:seed`

##### Start Rails Server  

    bin/rails server

##### (Optional) Generate ERD diagram
Following command will generate erd diagram in application root path through erd-rails gem

    bin/bundle exec erd

## Testing

##### Prepare test database

    bin/rails db:test:prepare

##### Run specs

    bin/bundle exec rspec


## Deployment
We are using Capistrano as deployment tool

##### Setup Initial Deployment
Check and create directory structure with `deploy:check`

    bin/bundle exec cap staging deploy:check

Make a copy of linked_files for new server with `config:init`

    bin/bundle exec cap staging config:init

Fetch existing config with `config:pull`

    bin/bundle exec cap staging config:pull

Push server configuration with `config:push`

    bin/bundle exec cap staging config:push

##### Setup Puma and Nginx configuration
Generate Puma and Nginx configuration templates

    bin/rails g capistrano:nginx_puma:config

Upload Puma and Nginx configurations

    bin/bundle exec cap staging puma:config
    bin/bundle exec cap staging puma:nginx_config


##### Deploy the new release via Capistrano

    bin/bundle exec cap staging deploy
