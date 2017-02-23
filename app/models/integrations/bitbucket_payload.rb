# == Schema Information
#
# Table name: payloads
#
#  id             :integer          not null, primary key
#  info           :text
#  integration_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  event          :string
#  type           :string
#

class BitbucketPayload < SourceCodePayload

  # SEE ACTUAL PAYLOAD SAMPLE IN `spec/files/sample_bitbucket_payload.yaml`

  # SAMPLE PAYLOAD
  #---
  #parameters:
  #  actor: &1
  #    display_name: Abdur Rehman
  #    username: hafizabi
  #    links:
  #      html:
  #        href: https://bitbucket.org/hafizabi/
  #    type: user
  #  push: &2
  #    changes:


  # RETURN_FORMAT => {
  #     event: 'push',
  #     pusher: 'dev one',
  #     commits:
  #         [
  #             {message: 'my awesome commit on friday', author: {email: 'author1@example.com', name: 'Foo Bar'}},
  #             {message: 'my super-awesome reply on saturday', author: {email: 'author1@example.com', name: 'Don Joe'}}
  #         ]
  # }
  # TODO --- CHECK ORDERING OF COMMITS
  def normalized_push_payload
    messages = info['push']['changes'][0]['commits'].map do |commit|
      {
          message: "#{commit['message']}",
          author: {
              email: "#{commit['author']['raw'].split('<')[0]}",
              name: "#{commit['author']['raw'].split('<')[1].remove('>')}"
          }
      }
    end

    {
        event: 'push',
        pusher: info['actor']['display_name'],
        commits: messages
    }
  end


  # def push
  #   commits = info["push"]["changes"][0]["commits"]
  #   total_commits = commits.count
  #   pusher = info["actor"]["display_name"]
  #   message_header = "#{total_commits} new commits pushed by #{pusher}"
  #   head_name = info["repository"]["full_name"]
  #   head_url = info["repository"]["links"]["html"]["href"] + "/commits"
  #
  #   message = {"head": "#{message_header}", "head_name": "#{head_name}", "head_url": "#{head_url}", "vcs_name": "bitbucket", "commits": []}
  #
  #   commits.each do |commit|
  #     id = commit["hash"]
  #     url = commit["links"]["html"]["href"]
  #     commit_message = "#{commit["message"]} - #{commit["author"]["raw"]}"
  #     commit_info = {"id": "#{id}", "url": "#{url}", "message": "#{commit_message}"}
  #     message[:commits] << commit_info
  #   end
  #
  #   message
  # end
end
