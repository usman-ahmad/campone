class NotificationsController < ApplicationController
  def index
      @notifications = Notification.where(user_id: current_user).order("created_at desc")
      # .group_by {|n| n.activity.trackable_type != 'Comment' ? n.activity.trackable_id : n.activity.trackable.commentable_id }
  end
end
