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

    create_webhook(external_project_id)
  end

  def import_task(task_id)
    task = @client.tasks.find_by_id task_id

    # TODO: handle assigned_to
    attributes = {
        title: task.name,
        description: task.notes,
        progress: task.completed ? Task::PROGRESS_MAP[:COMPLETED] : Task::PROGRESS_MAP[:NO_PROGRESS],
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
        projects << { title: p.title, id: p.id }
      end
    end

    projects
  end

  def create_webhook(id)
    # Make sure you have SSL in order to work wiht asana webhooks
    client.webhooks.create(resource: id, target: "#{ENV['HOST']}/webhooks/#{@integration.id}")
  end

  def create_task_from_payload(payload)
=begin
    Todo: Use Background job, And delay this job for some time i-e 5-10 minutes
    # when we receive task created hook, It is empty at this point as
    # Asana creates empty task on pressing enter than updates it gradually as user enters description.
=end
    if payload.info['events']
      events = payload.info['events'].select{|e| e['type'] == 'task' && e['action'] == 'added'}

      events.each do |event|
        import_task(event['resource'])
      end
    end
  end


end
