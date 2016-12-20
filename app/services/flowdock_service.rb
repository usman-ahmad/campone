class FlowdockService < SenderService

  def initialize(uri, params)
    super(uri, params)
  end

  def self.message(activity)
    {
        "event": "activity",
        "author": {
            "name": "#{activity.owner.email}",
            # "avatar": "https://avatars.githubusercontent.com/u/3017123?v=3"
        },
        "title": "#{activity.activty_type}#{':' + activity.trackable.content if activity.trackable_type == 'Comment'}",
        "external_thread_id": "#{activity.get_trackable.id}", #it should be trackable id
        "thread": {
            "title": "Project: #{activity.project.title} > #{activity.get_trackable.title}",
            # "body": "If there is any discription it will go here",
            "external_url": "#{activity.get_trackable_url}",
            "status": {
                "color": "green",
                "value": "#{activity.get_trackable.state}"
            }
        }
    }
  end
end
