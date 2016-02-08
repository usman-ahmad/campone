class AsanaImport
  # TODO: There should be one import against one project, Do't make redundant tasks
  attr_reader :client

  def initialize(integration)
    @project = integration.project
    @client = Asana::Client.new do |c|
      c.authentication :oauth2,
                       refresh_token: integration.token,
                       client_id:     ENV['ASANA_CLIENT_ID'],
                       client_secret: ENV['ASANA_CLIENT_SECRET'],
                       redirect_uri:  ENV['ASANA_REDIRECT_URI']
    end
  end

  def run!
    # For now i am selecting first project of first workspace, we should ask user to select a project.
    project_id = client.projects.find_all(workspace: client.workspaces.find_all.first.id).first.id

    tasks = client.tasks.find_by_project projectId: project_id, per_page: 2

    # TODO: Change it, for now importing just 2 tasks for testing
    tasks.first(2).each do |task|
      # Use Background Job here
      import_task(task.id)
    end
  end

  def import_task(task_id)
    task = @client.tasks.find_by_id task_id

    # TODO: handle assigned_to
    attributes = {
        title: task.name,
        description: task.notes,
        progress: task.completed ? 'Completed' : 'No progress',
        created_at: task.created_at,
        updated_at: task.modified_at
    }

    @project.tasks.create(attributes)
  end

end
