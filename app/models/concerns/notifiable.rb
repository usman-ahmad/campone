# Usage, in your model include Notifiable module like `include Notifiable`
# Call act_as_notifiable method. See act_as_notifiable for more details
# example: `act_as_notifiable performer: :performer, receivers: :notification_receivers, content_method: :title`

module Notifiable
  extend ActiveSupport::Concern

  # each class has its own configurations
  module ClassMethods
    attr_accessor :notifiable_config
  end

  included do
    extend(ClassMethods)
    after_commit :create_user_notifications, :broadcast_integrations, unless: :skip_notifications?
    has_many :notifications, as: :notifiable, dependent: :nullify

    # allowed parameters are performer, receivers and content_method
    # Your class must provide following methods
    # performer -> A method that must return Single Object ex. User.first
    # receivers -> A method returning Array of Objects like [User1, User2]
    # content_method -> A method returning content to be displayed. ex. 'your text here.'
    # only ->(optional) Array of notifiable attributes ex. only: [:title, :description] #
    #   by default all attributes are considered notifiable.
    #   all values of array will be converted to strings
    # except: (optional) Array of attributes on which you do not want to create notifications
    #   ex: except: [:position, :updated_at] (make sure to pas updated_at)
    # TODO: Provide support for Proc and Lambda
    def self.act_as_notifiable(options={})
      self.notifiable_config = {
          performer: options[:performer],
          receivers: options[:receivers],
          content_method: options[:content_method],
          notifiable_integrations: options[:notifiable_integrations],
          notifiable_attributes: options[:only].try(:map, &:to_s) || self.send(:attribute_names),
          on: options[:on] || [:create, :update, :destroy],
          if: options[:if]
      }.with_indifferent_access

      self.notifiable_config[:notifiable_attributes] -= options[:except].try(:map, &:to_s) if options[:except].present?
    end
  end

  def notification_content
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

    # TODO: store this hash into a variable to improve performance
    {
        resource_id: self.id,
        resource_type: self.class.name,
        resource_fid: self.try(:friendly_id), # friendly_id not implemented for discussion, we can show project_fid
        project_fid: self.project.friendly_id,
        resource_link: notifiable_link, # we can make url at run time, but for performance creating it here.
        performer_name: performer.try(:name),
        performer_id: performer.try(:id),
        action: action,
        text: notification_text
    }
  end

  def create_user_notifications
    # TODO: Decrease number of queries and write specs for notifications
    receivers.each do |receiver|
      Notification.create(receiver: receiver, performer: performer, notifiable: self, content: notification_content)
    end
  end

  # broadcast on notifiable integrations
  def broadcast_integrations
    notifiable_integrations.each do |integration|
      # TODO: Delete unused services
      # SenderService.build(integration, notification_content.merge(extra_info)).deliver
      integration.publish(notification_content.merge(extra_info))
    end
  end

  private

  def notifiable_link
    resource =
        case self.class.name
          when 'Task', 'Discussion'
            self
          when "Comment"
            self.commentable
        end

    pluralize_resource = resource.class.model_name.collection
    resource_id = resource.try(:friendly_id) || resource.id

    # Its better to start URL with '/' otherwise it will make them relative to page.
    "/projects/#{project.friendly_id}/#{pluralize_resource}/#{resource_id}"
  end

  def resource_action
    "#{notification_content[:action]} #{notification_content[:resource_type]}"
  end

  def extra_info
    {
        project_title: self.project.title,
        description: notifiable_description,
        absolute_url: ENV['HOST'] + notification_content[:resource_link]
    }
  end

  # TODO: Simplify
  # used while broadcasting on notifiable_integrations
  def notifiable_description
    text = case notification_content[:resource_type]
             when 'Task', 'Discussion'
               "#{notification_content[:performer_name]}: " + resource_action
             when "Comment"
               "#{notification_content[:performer_name]}: " + resource_action + ': '+ notification_content[:text]
           end

    ActionController::Base.helpers.strip_tags text
  end

  def notifiable_config
    self.class.notifiable_config
  end

  def notifiable_integrations
    notifiable_config[:notifiable_integrations].call(self) || []
  end

  def performer
    self.send(notifiable_config[:performer])
  end

  def receivers
    self.send(notifiable_config[:receivers]) || []
  end

  def notification_text
    ActionController::Base.helpers.strip_tags(self.send(notifiable_config[:content_method]))
  end

  def changed_notifiable_attributes
    previous_changes.keys & notifiable_config[:notifiable_attributes]
  end

  def skip_notifications?
    given = notifiable_config[:if].is_a?(Proc) ? notifiable_config[:if].call(self) : true
    event_performed = transaction_include_any_action?(notifiable_config[:on])
    (!given) || (!event_performed) || changed_notifiable_attributes.blank? || (receivers.blank? && notifiable_integrations.blank?)
  end
end
