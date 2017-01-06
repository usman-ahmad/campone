class FlowdockService < SenderService

  def initialize(uri, params)
    super(uri, params)
  end

  def self.message(activity)
    {
        "event": "activity",
        "author": {
            "name": "#{activity[:performer_name]}",
            # "avatar": "https://avatars.githubusercontent.com/u/3017123?v=3"
        },
        "title": activity[:text],
        "external_thread_id": "#{activity[:resource_id]}", #it should be trackable id
        "thread": {
            "title": "Project: #{activity[:project_title]} > #{activity[:text]}",
            # "body": "If there is any discription it will go here",
            "external_url": "#{activity[:absolute_url]}",
            "status": {
                "color": "green",
                # TODO: Set Correct value
                "value": "OK"
            }
        }
    }
  end
end
