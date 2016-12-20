class HipchatService < SenderService

  def initialize(uri, params)
    super(uri, params)
  end

  def self.message(activity)
    {
        "from": "Camp One",
        "message": "Project: #{activity.project.title} -
                    #{activity.get_trackable.title} -
                    #{activity.get_trackable_url} -
                    #{activity.discription}"
    }
  end
end
