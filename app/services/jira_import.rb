require 'jira'

class JiraImport
  attr_reader :client

  def initialize(integration)
    @project = integration.project

    options = {
        private_key_file: ENV['JIRA_PRIVATE_KEY_FILE'],
        consumer_key:     ENV['JIRA_CONSUMER_KEY'],
        site:             ENV['JIRA_SITE_URL'],
        context_path:     ''
    }

    @client = JIRA::Client.new(options)
    @client.set_access_token(integration.token, integration.secret)
  end

  def run!
    project = client.Project.all.first

    issues = project.issues

    # TODO: Change it, for now importing just 2 tasks for testing
    issues.each do |issue|
      # Use Background Job here
      import_task(issue)
    end
  end

  def import_task(issue)

    # TODO: Fix raw Description.
    attributes = {
        title: issue.summary,
        description: issue.description,
        progress:    map_progress(issue.status.name),
        priority:    issue.priority.name,
        created_at:  issue.created,
        updated_at:  issue.updated
    }

    @project.tasks.create(attributes)
  end

  private

  def map_progress(progress)
    case progress
      when 'To Do'
        'No progress'
      when 'Done'
        'Completed'
      when 'In Progress'
        'In progress'
    end
  end
end