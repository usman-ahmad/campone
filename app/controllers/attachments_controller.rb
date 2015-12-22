class AttachmentsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :attachment, :through => :project

  before_action :set_project
  before_action :set_attachment,    only: [:edit, :update, :download]

  def index
    @attachments = @project.attachments
  end

  def new
    @attachment = @project.attachments.build
    @attachment.build_attachment_group
  end

  def create
    if params[:attachments_array].blank?
      flash[:error] = "No file was attached."
    elsif @project.create_attachments(params[:attachments_array], params[:attachment])
      redirect_to project_attachments_path(@project), notice: 'Attachment was successfully created.'
    end

    flash[:error] ||= "#{@project.errors.full_messages.join(',')}"
    @attachment = @project.attachments.build
    render :new
  end

  def download
=begin
    TODO: Configure x_sendfile on Nginx and confirm its working
    To prevent ruby process to be busy on big files, hand over file download to web server
    # http://www.therailsway.com/2009/2/22/file-downloads-done-right/
    TODO: Security hole, Send_file with a parameter set by user is a security hole
    http://stackoverflow.com/questions/6392003/how-to-download-a-file-from-rails-application
=end
    send_file @attachment.attachment.path,
              :filename => @attachment.attachment_file_name,
              :type => @attachment.attachment_content_type,
              :disposition => 'attachment',
              :x_sendfile => true
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
    params.require(:attachment).permit(:attachment_group_id,:attachment_group_attributes => [:name]).merge(user: current_user)
  end
end
