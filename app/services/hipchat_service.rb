class HipchatService < SenderService

  def initialize(uri, params)
    super(uri, params)
  end

  def self.message(activity)
    {
        "from": "Camp One",
        "message": "Project: #{activity.project.name} -
                    #{activity.get_trackable.title} -
                    #{activity.get_trackable_url} -
                    #{activity.discription}"
    }
  end
end
