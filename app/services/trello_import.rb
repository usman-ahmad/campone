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
  end


  def import_list(list)
    # TODO: Should we create a TaskGroup with list name OR it should map to Task Progress?
    group = TaskGroup.find_or_create_by(name: list.name, project_id: @project.id)

    list.cards.each do |card|
      import_task(card, group.id)
    end
  end

  def import_task(card, group_id)
    # TODO: Manage Progress and Task Creator
    attributes = {
        title: card.name,
        description: card.desc,
        due_at: card.due,
        updated_at: card.last_activity_date,
        task_group_id: group_id
    }

    task = @project.tasks.build(attributes)

    card.attachments.each do |attachment|
      task.attachments.build(project: @project).attach_from_url(attachment.url)
    end

    task.save!
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
