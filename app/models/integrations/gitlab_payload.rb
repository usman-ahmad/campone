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

class GitlabPayload < SourceCodePayload

  # SEE ACTUAL PAYLOAD SAMPLE IN `spec/files/sample_gitlab_payload.yaml`

  # SAMPLE PAYLOAD
  # object_kind: push
  # user_name: "John Smith"
  # user_email: "john@example.com"
  # project_id: 15
  # repository:
  #  name: Diaspora
  #  git_http_url: "http://example.com/mike/diaspora.git"
  #  git_ssh_url: "git@example.com:mike/diaspora.git"
  # commits:
  #  -
  #    id: b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327
  #   message: "Update Catalan translation to e38cb41."
  #   timestamp: "2011-12-12T14:27:31+02:00"
  #   url: "http://example.com/mike/diaspora/commit/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327"
  #   author:
  #    name: "Jordi Mallach"
  #    email: "jordi@softcatala.org"
  #   id: da1560886d4f094c3e6c9ef40349f7d38b5d27d7
  #   message: "fixed readme"
  #   timestamp: "2012-01-03T23:36:29+02:00"
  #   url: "http://example.com/mike/diaspora/commit/da1560886d4f094c3e6c9ef40349f7d38b5d27d7"
  #   author:
  #    name: "GitLab dev user"
  #    email: "gitlabdev@dv6700.(none)"
  # total_commits_count: 4

  # RETURN_FORMAT => {
  #     event: 'push',
  #     pusher: 'dev one',
  #     commits:
  #         [
  #             {message: 'my awesome commit on friday', author: {email: 'author1@example.com', name: 'Foo Bar'}},
  #             {message: 'my super-awesome reply on saturday', author: {email: 'author1@example.com', name: 'Don Joe'}}
  #         ]
  # }
  def normalized_push_payload

    commits = info['commits'].map do |commit|
      {
          message: "#{commit['message']}",
          author: {
              email: "#{commit['author']['email']}",
              name: "#{commit['author']['name']}"
          }
      }
    end

    {
        event: 'push',
        pusher: info['user_name'],
        commits: commits
    }
  end
end
