class AttachmentsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :attachment, :through => :project

  # UA[2016/12/07] - 'set_project' and 'set_attachment' SHOULD NOT BE HERE
  # @project and @attachment SHOULD BE SET BY 'load_and_authorize_resource'
  before_action :set_project
  before_action :set_attachment, only: [:edit, :update, :download]

  def index
    @attachments = @project.attachments
    @attachment = Attachment.new(project: @project)
  end

  def show
  end

  def new
    @attachment = @project.attachments.build
  end

  def create
    @attachment = @project.attachments.new(attachment_params)

    if @attachment.save
      flash[:notice]= 'Attachment was successfully created.'
      redirect_to project_attachments_path(@project)
    else
      # flash[:error] = @attachment.errors.full_messages.join(',')
      render :new
    end
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
    if @attachment.update(attachment_params.except(:attachment))
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
    params.require(:attachment).permit(:title, :description, :attachment).merge(uploader: current_user)
  end
end
