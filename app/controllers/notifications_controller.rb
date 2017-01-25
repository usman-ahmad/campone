class NotificationsController < ApplicationController
  before_action :set_notification, only: [:update, :destroy]

  def index
    @notifications = Notification.where(receiver: current_user).order("created_at desc")
    @page = params[:page].try(:to_i) || 1

    respond_to do |format|
      # TODO: Delete this line and views/notifications/old_index_grouped.html.erb template
      # format.html { @notifications = @notifications.group_by { |n| n.story_or_discussion } }
      format.html { @notifications = @notifications.unscoped.paginate(page: @page, :per_page => 30) }
      format.js { @notifications = @notifications.paginate(:page => @page, :per_page => 10) }
    end
  end

  # this is used for marking a notifications as read
  def update
    respond_to do |format|
      format.json {

        # on successful update we decrease notification count from views using js
        # making sure that notification is unread before updating it
        # An other option is that we can calculate unread count on server side and sent it back with with response
        if !@notification.read? && @notification.update_attributes(read: true)
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
        current_user.notifications.update_all(read: true)
      }
    end
  end

  def clear_all
    respond_to do |format|
      format.js {
        # TODO: Update views only if this query is successful
        current_user.notifications.update_all(hidden: true)
      }
    end
  end

  def destroy
    if @notification.update_attributes(hidden: true)
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
