class ReplaysController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :task, :through => :project
  load_and_authorize_resource :discussion, :through => :project
  before_action :set_project, :load_commentable, :set_comment

  def new
   @replay = @comment.replays.build
  end

  def create
   if @comment.replays.create(replays_params)
     redirect_to [@project,@commentable], notice: "Replay posted."
   else
     render :new
   end
  end

  private
  def replays_params
    params.require(:replay).permit(:content).merge(user: current_user)
  end

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def load_commentable
    klass = [Task, Discussion].detect { |c| params["#{c.name.underscore}_id"] }
    @commentable = klass.find(params["#{klass.name.underscore}_id"])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
