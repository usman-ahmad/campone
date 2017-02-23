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

class SourceCodePayload < Payload
  # after_create :send_notification
  after_create :send_normalized_payload_to_integrations

  def send_normalized_payload_to_integrations
    integration.perform_actions!(normalized_push_payload)
  end

  # Sample return value:
  # {
  #     event: 'push',
  #     pusher: 'dev one',
  #     commits:
  #         [
  #             {message: 'message of commit 1', author: {email: 'author1@example.com', name: 'Foo Bar'}},
  #             {message: 'message of commit 2', author: {email: 'author1@example.com', name: 'Don Joe'}}
  #         ]
  # }
  def normalized_push_payload
    raise 'Method Missing.'
  end

  # TODO: Payload do not know about project users. move this method to integration
  # def send_notification
  #   #This will send notifications to Users of this project, On which payload is created
  #   NotificationService.new.send_notification(message[:head],project_user)
  # end

end
