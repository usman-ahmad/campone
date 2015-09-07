class DiscussionsController < ApplicationController
  before_action :set_project
  before_action :set_discussion,    only: [:show, :edit, :update, :destroy]

  def index
    @discussions = @project.discussions
  end

  def show
    @commentable = @discussion
    @comments = @commentable.comments
    @comment = Comment.new
  end

  def new
    @discussion = @project.discussions.new
    @discussion.build_discussion_group

    @project.members.each do |m|
      @discussion.user_discussions.build(user: m, notify: true )
    end
  end

  def create
    @discussion = @project.discussions.new(discussion_params)

    if @discussion.save
      redirect_to [@project, @discussion], notice: 'Discussion was successfully created.'
    else
      render :new
    end
  end

  def edit
    @discussion.build_discussion_group unless @discussion.discussion_group
    @discussion.discussion_group.name = nil
  end

  def update
    if @discussion.update(discussion_params)
      redirect_to [@project, @discussion], notice: 'Discussion was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @discussion.destroy
    redirect_to project_discussions_url, notice: 'Discussion was successfully destroyed.'
  end

  private

  def set_discussion
    @discussion = @project.discussions.find(params[:id])
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def discussion_params
    params.require(:discussion).permit(:title, :content, :project_id, :private, :discussion_group_id, :discussion_group_attributes => [:name],
                                       user_discussions_attributes: [:id, :user_id, :notify, :_destroy ])
  end

end
