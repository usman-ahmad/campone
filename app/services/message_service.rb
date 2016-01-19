class VcsMessages
  attr_accessor :payload
  attr_accessor :event

  def initialize(payload, event_name)
    @payload = payload
    @event = event_name
  end

  def message
    if self.respond_to? @event
      self.send event, @payload
    else
      raise NoMethodError.new("#{event} not implemented")
    end
  end

  #Format of push event message
  # {:head=>"2 new commits pushed by muhammad-ateek",
  #  :head_url=>"HEAD_URL",
  #  :commits=>[
  #      {
  #          :id=>"1c8...",
  #          :url=>"URL",
  #          :message=>"commit name - commiter name"},
  #      {
  #           :id=>"1803...",
  #           :url=>"URL",
  #           :message=>"second_commit_name - commiter name"
  #       }
  #   ]
  # }
  def push(payload)
    commits = payload.info["commits"]
    total_commits = commits.count
    pusher = payload.info["pusher"]["name"]
    message_header = "#{total_commits} new commits pushed by #{pusher}"

    message = {"head": "#{message_header}", "head_url": "HEAD_URL", "commits": []}

    commits.each do |commit|
      id = commit["id"]
      url = commit["url"]
      commit_message = "#{commit["message"]} - #{commit["committer"]["name"]}"
      commit_info = {"id": "#{id}", "url": "#{url}", "message": "#{commit_message}"}
      message[:commits] << commit_info
    end

    return message
  end

end