class BitbucketParser < VCSParser
  def initialize(payload)
    super(payload)
  end

  #Formate defined in Parent Class
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


  #Formate defined in Parent Class
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
