# Usage, in your model include Notifiable module like `include Notifiable`
# Call act_as_notifiable method. See act_as_notifiable for more details
# example: `act_as_notifiable performer: Proc.new{Current.user}, receivers: :notification_receivers, content_method: :title`

module Notifiable
  extend ActiveSupport::Concern

  # each class has its own configurations
  module ClassMethods
    attr_accessor :notifiable_config
  end

  included do
    extend(ClassMethods)
    after_commit :create_user_notifications
    has_many :notifications, as: :notifiable, dependent: :nullify

    # allowed parameters are performer, receivers and content_method
    # Your class must provide following methods
    # performer -> A method that must return Single Object ex. User.first
    # receivers -> A method returning Array of Objects like [User1, User2]
    # content_method -> A method returning content to be displayed. ex. 'your text here.'
    # TODO: Provide support for Proc and Lambda
    def self.act_as_notifiable(options={})
      self.notifiable_config = {
          content_method: options[:content_method],
          receivers: options[:receivers],
          performer: options[:performer]
      }
    end
  end

  def create_user_notifications
    if transaction_include_any_action?([:create])
      action = 'Created'
    elsif transaction_include_any_action?([:destroy])
      action = 'Deleted'
    elsif transaction_include_any_action?([:update])
      action = 'Updated'

      # customize update method
      attrs = previous_changes.keys - ['id', 'updated_at']
      if attrs.count == 1
        #  make notification like updated title from this to that.
      else
        # too much updates, just say updated
      end
    end

    performer = self.send(notifiable_config[:performer])
    receivers = self.send(notifiable_config[:receivers])

    content = {
        resource_id: self.id,
        resource_type: self.class.name,
        resource_fid: self.try(:friendly_id), # friendly_id not implemented for discussion, we can show project_fid
        project_fid: self.project.friendly_id,
        resource_link: notifiable_link, # we can make url at run time, but for performance creating it here.
        performer_name: performer.try(:name),
        performer_id: performer.try(:id),
        action: action,
        text: self.send(notifiable_config[:content_method])
    }

    # TODO: Decrease number of queries and write specs for notifications
    receivers.each do |receiver|
      Notification.create(receiver: receiver, performer: performer, notifiable: self, content: content)
    end
  end


  def notifiable_link
    resource =
        case self.class.name
          when 'Task', 'Discussion'
            self
          when "Comment"
            self.commentable
        end

    pluralize_resource = resource.class.name.downcase.pluralize
    resource_id = resource.try(:friendly_id) || resource.id

    "/projects/#{project.friendly_id}/#{pluralize_resource}/#{resource_id}"
  end

  def notifiable_config
    self.class.notifiable_config
  end

end
