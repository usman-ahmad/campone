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

class GithubPayload < SourceCodePayload

  # SEE ACTUAL PAYLOAD SAMPLE IN `spec/files/sample_github_payload.yaml`

  # SAMPLE PAYLOAD
  #---
  # parameters:
  #   ref: refs/heads/master
  #   before: 545d22f62fe5856315ce93898a3be1316202b86d
  #   after: f38ca7168056b5979befdf971bcce665cc2d8ae6
  #   created: false
  #   deleted: false
  #   forced: false
  #   base_ref:
  #   compare: https://github.com/hafizabi/train-one/compare/545d22f62fe5...f38ca7168056
  #   commits:
  #     id : f38ca7168056b5979befdf971bcce665cc2d8ae6
  #     tree_id : 71059265 b496a66f45673f298b877ca0b477e6bd
  #     distinct : true
  #     message : 'fix #OC-45'
  #     timestamp : '2017-02-09T15:19:28+05:00'
  #     url: https://github.com/hafizabi/train-one/commit/f38ca7168056b5979befdf971bcce665cc2d8ae6

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
    messages = info["commits"].map do |commit|
      {
          message: "#{commit["message"]}",
          author: {
              email: "#{commit["committer"]["email"]}",
              name: "#{commit["committer"]["name"]}"
          }
      }
    end

    {
        event: 'push',
        pusher: info["pusher"]["name"],
        commits: messages
    }
  end
end
