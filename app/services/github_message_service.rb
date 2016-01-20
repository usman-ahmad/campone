class Github < Vcsmessage

  def initialize(payload, event_name)
    super(payload,event_name,"github")
  end

  #Format of push event message
  # {:head=>"2 new commits pushed by muhammad-ateek",
  #  :head_url=>"HEAD_URL",
  #  :vcs_name =>"github",
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
    commits = payload["commits"]
    total_commits = commits.count
    pusher = payload["pusher"]["name"]
    message_header = "#{total_commits} new commits pushed by #{pusher}"

    message = {"head": "#{message_header}", "head_url": "HEAD_URL", "vcs_name":"github","commits": []}

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