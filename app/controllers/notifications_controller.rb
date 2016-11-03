class NotificationsController < ApplicationController
  def index
    @notifications = Notification.where(user_id: current_user).order("created_at desc")

    respond_to do |format|
      format.html { @notifications = @notifications.group_by { |n| n.task_or_discussion }}
      format.js   { @notifications = @notifications.first(10) }
    end
  end
  def update
    respond_to do |format|
      format.json {
        ids = JSON.parse(params[:data_value])
        notifications = Notification.where(id: ids)
        updated_count = notifications.update_all(status: 'read')
        render json: { decreasedUnreadCount: updated_count }, status: 200
      }
    end
  end

  def mark_all_read
    respond_to do |format|
      format.js {
        current_user.notifications.update_all(status: 'read')
      }
    end
  end
end
