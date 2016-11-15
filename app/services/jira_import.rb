require 'jira-ruby'

class JiraImport < ImportService

  def set_client
    options = {
        private_key_file: ENV['JIRA_PRIVATE_KEY_FILE'],
        consumer_key:     ENV['JIRA_CONSUMER_KEY'],
        site:             ENV['JIRA_SITE_URL'],
        context_path:     ''
    }

    @client = JIRA::Client.new(options)
    @client.set_access_token(@integration.token, @integration.secret)
  end

  def import!(external_project_id)
    project = client.Project.find(external_project_id)

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

  def project_list
    projects = []

    jira_projects = client.Project.all
    jira_projects.each do |p|
      projects << {name: p.name , id: p.id }
    end

    projects
  end


  def create_webhook(project_id)
    hook = @client.Webhook.build
    hook.save("name": "Camp One",
              "url": "#{ENV['HOST']}/webhooks/#{@integration.id}",
              "events": [
                  "jira:issue_created",
              ],
              "jqlFilter": "Project = #{project_id}",
              "excludeIssueDetails": false,
    )
  end

  def create_task_from_payload(payload)
    issue = client.Issue.find(payload.info['issue']['id'])
    import_task(issue)
  end

  private

  def map_progress(progress)
    case progress
      when 'To Do'
        Task::PROGRESS_MAP[:NO_PROGRESS]
      when 'Done'
        Task::PROGRESS_MAP[:COMPLETED]
      when 'In Progress'
        Task::PROGRESS_MAP[:IN_PROGRESS]
    end
  end
end
