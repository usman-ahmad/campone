class AttachmentsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :attachment, :through => :project

  # UA[2016/12/07] - 'set_project' and 'set_attachment' SHOULD NOT BE HERE
  # @project and @attachment SHOULD BE SET BY 'load_and_authorize_resource'
  before_action :set_project
  before_action :set_attachment, only: [:edit, :update, :download]

  before_action :set_performer, only: [:create, :update, :destroy]

  def index
    @attachments = @project.attachments
    @attachment = ProjectAttachment.new(project: @project)
  end

  # UA[2016/12/08] - WRONG STYLE PARAMETER PASSING - RECHECK THE VIEW LAYER AND REFACTOR PARTIALS
  def show
    @comments = @attachment.comments
    @comment = Comment.new
    @commentable = @attachment
  end

  def new
    @attachment = @project.attachments.build
  end

  def create
    @attachment = @project.attachments.new(attachment_params.except(:attachment_name))

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
    send_file @attachment.document.path,
              :filename => @attachment.document_file_name,
              :type => @attachment.document_content_type,
              :disposition => 'attachment',
              :x_sendfile => true
  end

  def destroy
    @attachment = ProjectAttachment.find(params[:id])
    @attachment.destroy
    redirect_to project_attachments_path(@project), notice: 'Attachment was successfully deleted.'
  end

  def edit
  end

  def update
    if @attachment.update(attachment_params.except(:document))
      redirect_to project_attachment_path(@project, @attachment), notice: 'Attachment was successfully updated.'
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
    params.require(:attachment).permit(:title, :description, :document, :attachment_name).merge(uploader: current_user)
  end

  def set_performer
    @attachment.performer = current_user
  end
end
