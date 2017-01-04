# Usage, in your model include Notifiable module like `include Notifiable`
# Call act_as_notifiable method.
# You class must provide following methods
# notification_performer -> Must return Single Object ex. User.first
# notification_receivers -> Returning Array of Objects ex [User.first(2)]
# notification_content -> Should return content to be displayed. ex. 'you text here.'
# You can override these methods by passing parameters to act_as_notifiable, see method

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
    # ex: `act_as_notifiable performer: :custom_reporter, receivers: :custom_receivers, content_method: :title`
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

    puts "NOTIFICATION: "
    puts "#{notifiable_config[:performer].try(:name) rescue nil} #{action} #{self.class.name}"
    puts "Notification_receivers: ", self.send(notifiable_config[:receivers]).compact.map(&:id).inspect rescue nil
  end

  def notifiable_config
    self.class.notifiable_config
  end

end
