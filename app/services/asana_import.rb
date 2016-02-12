class AsanaImport < ImportService

  def set_client
    @client = Asana::Client.new do |c|
      c.authentication :oauth2,
                       refresh_token: @integration.token,
                       client_id:     ENV['ASANA_CLIENT_ID'],
                       client_secret: ENV['ASANA_CLIENT_SECRET'],
                       redirect_uri:  ENV['ASANA_REDIRECT_URI']
    end
  end

  def import!(external_project_id)
    tasks = client.tasks.find_by_project projectId: external_project_id

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

  def project_list
    projects = []

    workspaces =  client.workspaces.find_all
    workspaces.each do |ws|
      ws_projects = client.projects.find_all(workspace: ws.id)

      ws_projects.each do |p|
        projects << { name: p.name, id: p.id }
      end
    end

    projects
  end

end
