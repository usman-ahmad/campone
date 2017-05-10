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

require 'trello'

class TrelloIntegration < ImportIntegration

  def client
    @client ||= Trello::Client.new(
        :consumer_key => ENV['TRELLO_KEY'],
        :consumer_secret => ENV['TRELLO_SECRET'],
        :oauth_token => self.token,
        :oauth_token_secret => self.secret
    )
  end

  def self.create_with_omniauth(project, auth)
    find_or_create_by(name: auth.provider, url: auth.info.urls.profile, project: project) do |integration|
      integration.token = auth.credentials.token
      integration.secret = auth.credentials.secret
    end
  end

  def import!(external_project_id)
    # external_project_id us actually Board id
    board = client.find(:board, external_project_id)
    board.lists.each do |list|
      import_list(list)
    end

    # TODO: We are not going to create webhooks now. Remove this method also
    # To automatically sync
    # create_webhook(external_project_id)
  end


  def import_list(list)
    list.cards.each do |card|
      import_story(card)
    end
  end

  def import_story(card)
    # TODO: Manage State and Story Requester
    attributes = {
        title: card.name,
        description: card.desc,
        due_at: card.due,
        updated_at: card.last_activity_date,
        performer: self.performer
    }

    story = self.project.stories.build(attributes)

    card.attachments.each do |attachment|
      story.attachments.build(project: @project).attach_from_url(attachment.url)
    end

    story.save!
  end

  def create_story_from_payload(payload)
    card_id = payload.info['webhook']['action']['data']['card']['id']
    # list_name = payload.info['webhook']['action']['data']['list']['name']
    card = client.find(:card, card_id)
    # group = StoryGroup.find_or_create_by(name: list_name, project_id: @project.id)
    # import_story(card, group.id)
    import_story(card)
  end

  def project_list
    configure

    boards = Trello::Board.all
    projects = []

    boards.each do |b|
      projects << {title: b.name, id: b.id}
    end

    projects
  end

  def configure
    # TODO: Consider thread safety
    Trello.configure do |config|
      config.consumer_key = ENV['TRELLO_KEY']
      config.consumer_secret = ENV['TRELLO_SECRET']
      config.oauth_token = self.token
      config.oauth_token_secret = self.secret
    end
  end

  # We are not creating webhooks for now
  # # TODO: Delete webhook, Gem does't provide a way to fetch all webhooks, Either store webhook id on local DB or patch gem
  # def create_webhook(model_id)
  #   client.create(:webhook,
  #                  'description' => 'Story sync for Camp One',
  #                  'idModel' => model_id,
  #                  'callbackURL' => "#{ENV['HOST']}/webhooks/#{@integration.id}")
  # end


=begin
    client = client = Trello::Client.new(
        :consumer_key => ENV['TRELLO_KEY'],
        :consumer_secret => ENV['TRELLO_SECRET'],
        :oauth_token => integration.token,
        :oauth_token_secret => integration.secret
    )

    Thread.new do
      client.find(:members, "member_id")
      client.find(:boards, "board_id")
    end
=end

end
