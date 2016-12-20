class SlackService < SenderService

  def initialize(uri, params)
    super(uri, params)
  end

  def self.message(activity)
    {
        "username": "Camp One",
        "attachments": [
            {
                "pretext": "Project: #{activity.project.title}",
                "title": activity.get_trackable.title,
                "title_link": activity.get_trackable_url,
                "text": activity.discription,
                "color": "#7CD197"
            }
        ]
    }
  end

end
