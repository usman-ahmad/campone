# == Schema Information
#
# Table name: integrations
#
#  id         :integer          not null, primary key
#  project_id :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  token      :string
#  secret     :string
#  type       :string
#  title      :string
#  active     :boolean
#  secure_id  :string
#

class AsanaIntegration < ImportIntegration

  def client
    @client ||= Asana::Client.new do |c|
      c.authentication :oauth2,
                       refresh_token: token,
                       client_id: ENV['ASANA_CLIENT_ID'],
                       client_secret: ENV['ASANA_CLIENT_SECRET'],
                       redirect_uri: ENV['ASANA_REDIRECT_URI']
    end
  end

  def self.create_with_omniauth(project, auth)
    find_or_create_by(name: auth.provider, project: project, url: 'https://app.asana.com/'+ auth.info.name) do |integration|
      integration.token = auth.credentials.refresh_token
    end
  end

  def import!(external_project_id)

    stories = client.tasks.find_by_project projectId: external_project_id

    stories.each do |story|
      # Use Background Job here
      import_story(story.id)
    end

    # TODO: We are not creating webhooks to synch for now. Remove this method also
    # create_webhook(external_project_id)
  end

  def import_story(story_id)
    story = client.tasks.find_by_id story_id

    # TODO: handle assigned_to
    attributes = {
        title: story.name,
        description: story.notes,
        state: story.completed ? Story::STATE_MAP[:COMPLETED] : Story::STATE_MAP[:NO_PROGRESS],
        created_at: story.created_at,
        updated_at: story.modified_at,
        performer: self.performer
    }

    self.project.stories.create(attributes)
  end

  def project_list
    projects = []

    workspaces = client.workspaces.find_all
    workspaces.each do |ws|
      ws_projects = client.projects.find_all(workspace: ws.id)

      ws_projects.each do |p|
        projects << {title: p.name, id: p.id}
      end
    end

    projects
  end

  # We are NOT creating webhook to synch changes for now.
  # TODO: FIX, Target URL is not valid
  #   def create_webhook(id)
  #     # Make sure you have SSL in order to work wiht asana webhooks
  #     client.webhooks.create(resource: id, target: "#{ENV['HOST']}/webhooks/#{@integration.id}")
  #   end

  def create_story_from_payload(payload)
    # Todo: Use Background job, And delay this job for some time i-e 5-10 minutes
    # when we receive story created hook, It is empty at this point as
    # Asana creates empty story on pressing enter than updates it gradually as user enters description.
    if payload.info['events']
      events = payload.info['events'].select { |e| e['type'] == 'story' && e['action'] == 'added' }

      events.each do |event|
        import_story(event['resource'])
      end
    end
  end
end
