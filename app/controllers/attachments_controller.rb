class AttachmentsController < ApplicationController
  before_action :set_project

  def index
    @attachments = @project.attachments
  end

  def new
    @attachment = @project.attachments.build
  end

  def create
    if @project.create_attachments params[:attachments_array]
      redirect_to project_attachments_path(@project), notice: 'Attachment was successfully created.'
    else
      @attachment = @project.attachments.build
      flash[:error] = "#{@project.errors.full_messages.join(',')}"
      render :new
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id])
    @attachment.destroy
    redirect_to project_attachments_path(@project), notice: 'Attachment was successfully deleted.'
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end
end
