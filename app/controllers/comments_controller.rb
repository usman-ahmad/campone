class CommentsController < ApplicationController
  before_action :set_project
  before_action :load_commentable

  def index
    @comments = @commentable.comments
  end

  def new
    @comment = @commentable.comments.new
  end

  def create
    @comment = @commentable.comments.new(comments_params)
    if @comment.save
      redirect_to [@project,@commentable], notice: "Comment created."
    else
      render :new
    end
  end

  private

  def comments_params
    params.require(:comment).permit(:content).merge(user: current_user)
  end
  # def load_commentable
  #   resource, id = request.path.split('/')[1, 2]
  #   @commentable = resource.singularize.classify.constantize.find(id)
  # end

  def load_commentable
    klass = [Task, Discussion].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end
end
