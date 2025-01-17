class CommentsController < ApplicationController
  before_action :set_project
  before_action :load_commentable
  before_action :comment, only: [:edit, :update, :destroy]

  before_action :set_performer, only: [:update, :destroy]

  # Make sure a user is not able comment on other unauthorized projects
  load_and_authorize_resource :project
  load_and_authorize_resource :story, :through => :project
  load_and_authorize_resource :discussion, :through => :project
  authorize_resource :comment, :through => [:story, :discussion]

  def index
    @comments = @commentable.comments
  end

  def new
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.new(comments_params)
    @comment.attachments_array=params[:attachments_array]
    @comment.performer = current_user

    # UA[2016/12/06] - MOVE THESE MODEL RELATED LOGIC TO AR_CALLBACKS
    if params[:add_files_to_project]
      @project.create_attachments(params[:attachments_array], current_user)
    end

    respond_to do |format|
      flash[:notice] = @comment.save ? 'Comment created.' : "Unable to create comment. #{@comment.errors.join(', ')}"
      format.html{ redirect_back fallback_location: [@project, @commentable]}
      format.json
    end
  end

  def edit
    @comment
  end

  def update
    if @comment.update(comments_params)
      redirect_to [@project, @commentable], notice: 'Comment updated.'
    end
  end

  def destroy
    @comment.destroy
    redirect_to :back, notice: 'Comment deleted.'
  end

  private
  def comments_params
    params.require(:comment).permit(:content)
  end

  # def load_commentable
  #   resource, id = request.path.split('/')[1, 2]
  #   @commentable = resource.singularize.classify.constantize.find(id)
  # end

  def comment
    @comment = Comment.find_by(id: params[:id])
  end

  def load_commentable
    klass = [Story, Discussion, Attachment].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_performer
    @comment.performer = current_user
  end
end
