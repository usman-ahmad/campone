class NotificationsController < ApplicationController
  def index
    @notifications = Notification.where(user_id: current_user).order("created_at desc")

    respond_to do |format|
      format.html { @notifications = @notifications.group_by { |n| n.activity.trackable_type != 'Comment' ? n.activity.trackable : n.activity.trackable.commentable }}
      format.js   { @notifications = @notifications.first(10) }
    end
  end
  def update
    respond_to do |format|
      format.json {
        array = JSON.parse(params[:data_value])
        id = array[0]
        Notification.find(id).update_attribute(:status, 'read')
      }
    end
  end
end
