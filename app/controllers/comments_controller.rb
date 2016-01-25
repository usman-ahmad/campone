class CommentsController < ApplicationController
  before_action :set_project
  before_action :load_commentable
  before_action :comment, only: [:edit, :update, :destroy]

  def index
    @comments = @commentable.comments
  end

  def new
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.new(comments_params)
    @comment.attachments_array=params[:attachments_array]

    if @comment.save
      @comment.create_activity :create, owner: current_user
      redirect_to [@project,@commentable], notice: "Comment created."
    else
      redirect_to [@project,@commentable], notice: "Please write comment"
    end
  end

  def edit
    @comment
  end

  def update
    @comment.attachments_array=params[:attachments_array]
    if @comment.update(comments_params)
      redirect_to [@project,@commentable], notice: "Comment updated."
    end
  end

  def destroy
    @comment.destroy
    redirect_to :back,  notice: "Comment deleted."
  end

  private
  def comments_params
    params.require(:comment).permit(:content, attachments_array: []).merge(user: current_user)
  end
  # def load_commentable
  #   resource, id = request.path.split('/')[1, 2]
  #   @commentable = resource.singularize.classify.constantize.find(id)
  # end

  def comment
    @comment = Comment.find_by(id:params[:id])
  end
  def load_commentable
    klass = [Task, Discussion].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
