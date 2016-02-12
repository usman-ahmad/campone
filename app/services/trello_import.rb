require 'trello'

class TrelloImport
  # TODO: There should be one import against one project, Do't make redundant tasks
  attr_reader :client

  def initialize(integration)
    @project = integration.project

    # TODO: Consider thread safety
    Trello.configure do |config|
      config.consumer_key = ENV['TRELLO_KEY']
      config.consumer_secret = ENV['TRELLO_SECRET']
      config.oauth_token = integration.token
      config.oauth_token_secret = integration.secret
    end

    @client = Trello.client
=begin

    # For thread safety:

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

  def run!
    # For now i am selecting first board
    boards  = Trello::Board.all

    lists = boards.first.lists

    # Use Background Job here
    lists.each do |list|
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

end
