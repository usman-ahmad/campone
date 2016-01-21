class GithubParser < VCSParser

  def initialize(payload)
    super(payload)
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
  def push
    commits = @payload["commits"]
    total_commits = commits.count # No need to store this in new variable, we can use commits.count
    pusher = @payload["pusher"]["name"]
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

=begin
  This method will return Commit message in this form
    {
        {message: 'messge of commit 1', author: {email: 'author1@example.com', name: 'Foo Bar'}},
        {message: 'messge of commit 2', author: {email: 'author1@example.com', name: 'Don Joe'}}
    }
=end

  def get_commit_messages
    commits = @payload["commits"]
    messages = []
    commits.each do |commit|
    commit_info = {
          message: "#{commit["message"]}",
          author: { email: "#{commit["committer"]["email"]}", name: "#{commit["committer"]["name"]}"}}
      messages << commit_info
    end
    return messages
  end

end