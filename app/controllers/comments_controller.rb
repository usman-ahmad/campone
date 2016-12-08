class CommentsController < ApplicationController
  before_action :set_project
  before_action :load_commentable
  before_action :comment, only: [:edit, :update, :destroy]

  # Make sure a user is not able comment on other unauthorized projects
  load_and_authorize_resource :project
  load_and_authorize_resource :task, :through => :project
  load_and_authorize_resource :discussion, :through => :project
  authorize_resource :comment, :through => [:task, :discussion]

  def index
    @comments = @commentable.comments
  end

  def new
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.new(comments_params)
    @comment.attachments_array=params[:attachments_array]

    # UA[2016/12/06] - MOVE THESE MODEL RELATED LOGIC TO AR_CALLBACKS
    if params[:add_files_to_project]
      @project.create_attachments(params[:attachments_array], current_user)
    end

    if @comment.save
      @comment.create_activity :create, owner: current_user
      redirect_to [@project, @commentable], notice: 'Comment created.'
    else
      redirect_to [@project, @commentable], notice: 'Please write comment'
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
    params.require(:comment).permit(:content).merge(user: current_user)
  end

  # def load_commentable
  #   resource, id = request.path.split('/')[1, 2]
  #   @commentable = resource.singularize.classify.constantize.find(id)
  # end

  def comment
    @comment = Comment.find_by(id: params[:id])
  end

  def load_commentable
    klass = [Task, Discussion, Attachment].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
