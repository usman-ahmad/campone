require 'trello'

class TrelloImport < ImportService

  def set_client
    @client = @client = Trello::Client.new(
        :consumer_key => ENV['TRELLO_KEY'],
        :consumer_secret => ENV['TRELLO_SECRET'],
        :oauth_token => @integration.token,
        :oauth_token_secret => @integration.secret
    )
  end


  def import!(external_project_id)
    # external_project_id us actually Board id
    board = @client.find(:board, external_project_id)
    board.lists.each do |list|
      import_list(list)
    end

    # To automatically sync
    create_webhook(external_project_id)
  end


  def import_list(list)
    list.cards.each do |card|
      import_task(card)
    end
  end

  def import_task(card)
    # TODO: Manage State and Task Reporter
    attributes = {
        title: card.name,
        description: card.desc,
        due_at: card.due,
        updated_at: card.last_activity_date,
    }

    task = @project.tasks.build(attributes)

    card.attachments.each do |attachment|
      task.attachments.build(project: @project).attach_from_url(attachment.url)
    end

    task.save!
  end

  def create_task_from_payload(payload)
    card_id = payload.info['webhook']['action']['data']['card']['id']
    # list_name = payload.info['webhook']['action']['data']['list']['name']
    card = @client.find(:card, card_id)
    # group = TaskGroup.find_or_create_by(name: list_name, project_id: @project.id)
    # import_task(card, group.id)
    import_task(card)
  end

  def project_list
    configure

    boards = Trello::Board.all
    projects = []

    boards.each do |b|
      projects  << { name: b.name, id: b.id }
    end

    projects
  end

  def configure
    # TODO: Consider thread safety
    Trello.configure do |config|
      config.consumer_key = ENV['TRELLO_KEY']
      config.consumer_secret = ENV['TRELLO_SECRET']
      config.oauth_token = @integration.token
      config.oauth_token_secret = @integration.secret
    end
  end

  # TODO: Delete webhook, Gem does't provide a way to fetch all webhooks, Either store webhook id on local DB or patch gem
  def create_webhook(model_id)
    @client.create(:webhook,
                   'description' => 'Task sync for Camp One',
                   'idModel'     => model_id,
                   'callbackURL' => "#{ENV['HOST']}/webhooks/#{@integration.id}")
  end


=begin
    @client = @client = Trello::Client.new(
        :consumer_key => ENV['TRELLO_KEY'],
        :consumer_secret => ENV['TRELLO_SECRET'],
        :oauth_token => integration.token,
        :oauth_token_secret => integration.secret
    )

    Thread.new do
      @client.find(:members, "member_id")
      @client.find(:boards, "board_id")
    end
=end

end
