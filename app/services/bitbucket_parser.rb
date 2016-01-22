class BitbucketParser < VCSParser
  def initialize(payload)
    super(payload)
  end

  #Format of push event message
  # {:head=>"2 new commits pushed by muhammad-ateek",
  #  :head_name => "username/repo_name"
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
    commits = @payload["push"]["changes"][0]["commits"]
    total_commits = commits.count
    pusher = @payload["actor"]["display_name"]
    message_header = "#{total_commits} new commits pushed by #{pusher}"
    head_name = @payload["repository"]["full_name"]
    head_url = @payload["repository"]["links"]["html"]["href"] + "/commits"

    message = {"head": "#{message_header}", "head_name": "#{head_name}", "head_url": "#{head_url}", "vcs_name": "bitbucket", "commits": []}

    commits.each do |commit|
      id = commit["hash"]
      url = commit["links"]["html"]["href"]
      commit_message = "#{commit["message"]} - #{commit["author"]["raw"]}"
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
    commits = @payload["push"]["changes"][0]["commits"]
    messages = []
    commits.each do |commit|
      commit_info = {
          message: "#{commit["message"]}",
          author: {email: "#{commit["author"]["raw"].split('<')[0]}", name: "#{commit["author"]["raw"].split('<')[1].remove('>')}"}}
      messages << commit_info
    end
    return messages
  end

end