# == Schema Information
#
# Table name: integrations
#
#  id         :integer          not null, primary key
#  project_id :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  token      :string
#  secret     :string
#  type       :string
#  title      :string
#  active     :boolean
#  secure_id  :string
#

class SourceCodeIntegrations < Integration

  def perform_actions!(normalized_payload)
    normalized_payload[:commits].each do |message_author|
      stories_affected = decode_commit_message(message_author[:message])

      stories_affected.each do |story_data|
        story = project.stories.find(story_data[:ticket_id])
        # TODO --- story.comment_that_commit_is_pushed
        update_story!(story, story_data[:action])
      end
    end
  end

  # This method will update story status (Performs any actions based on commit message)
  #
  # ### Example commit messages
  #
  # 'fix #ticket_01'
  # Des: will mark ticket_01 as completed, second form of verb can be used as action i-e fixes or fixed
  #
  # 'fix #ticket_01 #ticket_02'
  #  Des: will mark both as completed you can use comman (,) colon (:) and samicolon (;) to perform action on multiple tickets
  #
  # 'fixed #ticket_01 #ticket_02 and started #ticket_03'
  # # will make ticket_01 and 02 as completed and ticket_03 as started. Yes! you can define multiple actions in one commit
  #
  # # all available actions are
  # start|finish|complete|resolve|close|fix
  #
  # I know this function is scary but it works; will improve it later and more actions will be added
  # def perform_actions!(commit)
  def decode_commit_message(commit_message)
    separators = [',', ':', ';', ' ']
    # NoMethodError  (undefined method `scan' for #<Hash:0x0000000a2cc608>):
    # This method is raising an error. Priority : HIGH
    matches = commit_message.scan(/((start|finish|complete|resolve|close|fix)?e?s?d?\w?[\s,:;&]+#([-a-z0-9]+))/i)

    story_action_array = []
    matches.each_with_index do |match, index|
      ticket_id = match[2]
      action = match[1] || (matches[index-1][1] if index > 0 and separators.include?(match[0][0]))

      # story = project.stories.find(ticket_id.downcase)
      story_action_array << {
          ticket_id: ticket_id.downcase,
          action: action
      }
      # Determine and perform action to take
      # update_story!(story, action) if story
    end
    story_action_array
  end

  def update_story!(story, action)
    story.performer = User.first

    case action.downcase
      when 'start'
        # start the ticket
        # TODO: Using string to match Progress are pron to typo errors. should use named constants
        story.update_attributes(state: Story::STATE_MAP[:IN_PROGRESS]) if story.state == Story::STATE_MAP[:NO_PROGRESS]
      when 'close', 'fix', 'resolve', 'complete'
        # change status to finish
        story.update_attributes(state: Story::STATE_MAP[:COMPLETED])
      when nil
        # create comment on referenced ticket?
    end
  end
end
