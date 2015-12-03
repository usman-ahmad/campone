class AttachmentsController < ApplicationController
  before_action :set_project
  before_action :set_attachment,    only: [:edit, :update]

  def index
    @attachments = @project.attachments
  end

  def new
    @attachment = @project.attachments.build
    @attachment.build_attachment_group
  end

  def create
    if @project.create_attachments(params[:attachments_array], params[:attachment])
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

  def edit

  end

  def update
    if @attachment.update(attachment_params)
      redirect_to project_attachments_path(@project), notice: 'Attachment was successfully updated.'
    else
      render :edit
    end
  end

  private
  def set_attachment
     @attachment = @project.attachments.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def attachment_params
    params.require(:attachment).permit(:attachment_group_id, :attachment_group_attributes => [:name])
  end
end
