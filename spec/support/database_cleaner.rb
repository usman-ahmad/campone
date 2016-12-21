RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  # Configure DatabaseCleaner to use truncation strategy with
  # JavaScript (js: true) specs.
  #
  # We want to ensure we're not using transactions as the work they do is
  # isolated to one database connection. One database connection is used by
  # the specs, and another, separate database connection is
  # used by the app server phantomjs interacts with. Truncation, when *not*
  # inside a transaction, affects all database connections, so truncation is
  # what we need!
  # http://www.railsonmaui.com/tips/rails/capybara-phantomjs-poltergeist-rspec-rails-tips.html
  # http://devblog.avdi.org/2012/08/31/configuring-database_cleaner-with-rails-rspec-capybara-and-selenium/
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    # Test files are not properly cleaned from file system. Paperclip adds some hooks
    # A before_destroy hook `queue_all_for_delete` saves all files in instance variable `@queued_for_delete`
    # Then another hook (after_commit, on: destroy) deletes the @queued_for_delete files from file system.
    # These hooks properly works if we call `attachment.destroy` in rails console
    # But having issue when rspec implicitly destroys objects (Garbage collection)
    # Similar issue is reported (after_commit not being called) but this has been fixed in rails 5.0
    # https://github.com/thoughtbot/paperclip/issues/1445

    # Workaround for destroying test files, destroy all models having paperclip attachments
    Attachment.destroy_all
    DatabaseCleaner.clean
  end
end
