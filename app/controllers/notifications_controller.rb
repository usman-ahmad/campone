class NotificationsController < ApplicationController
  def index
    @notifications = Notification.where(user_id: current_user).order("created_at desc")
                         .group_by { |n| n.activity.trackable_type != 'Comment' ? n.activity.trackable : n.activity.trackable.commentable }
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
