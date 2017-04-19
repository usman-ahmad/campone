class NotificationSettingsController < ApplicationController

  def index
    @in_app_notification_setting = current_user.in_app_notification_setting
    @email_notification_setting = current_user.email_notification_setting
  end

  def update
    @notification_settings = NotificationSetting.find(params[:id])

    respond_to do |format|
      if @notification_settings.update(notification_setting_params)
        format.html { redirect_to notification_settings_path, notice: 'Settings successfully updated.' }
      else
        format.html { render :index }
      end
    end
  end

  private

  def notification_setting_params
    params.require(:notification_setting).permit(:new_story, :ownership_change, :story_state, :comments, :commits, :enable)
  end
end
