# Setup Development Enviroment

### Step 1: (Some Basic Steps):
- #### Install RVM
Install RVM (development version):

        gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
        \curl -sSL https://get.rvm.io | bash

- #### Install GIT

        sudo apt-get install git

- #### Install PostgreSQL

        sudo apt-get update
        sudo apt-get install postgresql postgresql-client postgresql-contrib libpq-dev phppgadmin

### Step 2: (Install Ruby):
- Install ruby 2.2.2

        rvm install 2.2.2

### Step 3: (System Dependencies):
we are using "faye" for notifications which depends on node.js.
Install Nodejs

- To install nodejs first we need to instal nvm (Node.js version manager).

        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash

- Install Node v4.0.0

        nvm install 4.0.0

- Usually, nvm will switch to use the most recently installed version. You can explicitly tell nvm to use the version we just downloaded by typing:

        nvm use 4.0.0

Install redis for ActionCable

    sudo apt-get install redis-server

Nokogiri prereuisities:

    sudo apt-get install libxslt-dev libxml2-dev

### Step 4: (Clone Porject):

    git clone git@bitbucket.org:teknuk/camp_one.git
    cd camp_one

### Step 5: (Install gem using bundler):

    gem install bundler
    bundle install

### Step 6: (Configuration):

    cp config/database.yml.sample config/database.yml
    cp .env.sample .env
    Now fill newely created database.yml and .env with you credentials.

### Step 7: (Database creation):

    rake db:create
    rake db:migrate

### Step 7: (Database Initialization):
- To install the seeds into your local DB:

        rake db:seed

### Step 8: (To run the local development server):
1. To start notifications Properly we need to start thin server so run following command to properly start server for faye

        rackup private_pub.ru -s thin -E production

2. Starting Rails Server

        rails s

###  How to run the test suite
- Prepare test database:

        rake db:test:prepare
- Run specs:

        bundle exec rspec spec

### Genrate ERD diagram
1. Following command will generate erd diagram in application root path through erd-rails gem
        bundle exec erd

###  Deployment instructions
We are using mina as deployment tool

        gem install mina
        mina deploy
