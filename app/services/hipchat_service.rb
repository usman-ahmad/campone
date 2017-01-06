class HipchatService < SenderService

  def initialize(uri, params)
    super(uri, params)
  end

  def self.message(activity)
    {
        "from": "Camp One",
        "message": "Project: #{activity[:project_title]} -
                    #{activity[:text]} -
                    #{activity[:absolute_url]} -
                    #{activity[:description]}"
    }
  end
end
