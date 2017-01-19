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
    stories = client.stories.find_by_project projectId: external_project_id

    # TODO: Change it, for now importing just 2 stories for testing
    stories.first(2).each do |story|
      # Use Background Job here
      import_story(story.id)
    end

    create_webhook(external_project_id)
  end

  def import_story(story_id)
    story = @client.stories.find_by_id story_id

    # TODO: handle assigned_to
    attributes = {
        title: story.name,
        description: story.notes,
        state: story.completed ? Story::STATE_MAP[:COMPLETED] : Story::STATE_MAP[:NO_PROGRESS],
        created_at: story.created_at,
        updated_at: story.modified_at
    }

    @project.stories.create(attributes)
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

  def create_story_from_payload(payload)
=begin
    Todo: Use Background job, And delay this job for some time i-e 5-10 minutes
    # when we receive story created hook, It is empty at this point as
    # Asana creates empty story on pressing enter than updates it gradually as user enters description.
=end
    if payload.info['events']
      events = payload.info['events'].select{|e| e['type'] == 'story' && e['action'] == 'added'}

      events.each do |event|
        import_story(event['resource'])
      end
    end
  end


end
