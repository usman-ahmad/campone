class NotificationsController < ApplicationController
  before_action :set_notification, only: [:update, :destroy]

  def index
    @notifications = Notification.where(user_id: current_user).order("created_at desc")
    @page = params[:page].try(:to_i) || 1

    respond_to do |format|
      format.html { @notifications = @notifications.group_by { |n| n.task_or_discussion }}
      format.js   { @notifications = @notifications.paginate(:page => @page, :per_page => 10) }
    end
  end

  def update
    respond_to do |format|
      format.json {
        if @notification.update_attributes(status: 'read')
          render json: {}, status: :ok
        else
          render json: @notification.errors, status: :unprocessable_entity
        end
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

  def destroy
    if @notification.update_attributes(is_deleted: true)
      render json: {}, status: :ok
    else
      render json: {status: 'Not Deleted'}, status: :unprocessable_entity
    end
  end

  private
  def set_notification
    @notification = Notification.find(params[:id])
  end
end
