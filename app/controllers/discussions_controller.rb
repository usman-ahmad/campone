class DiscussionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :discussion, :through => :project

  before_action :set_project
  before_action :set_discussion,    only: [:show, :edit, :update, :destroy]
  before_action :build_user_discussions, only: [:edit]

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
    @discussion.attachments.build

    @project.members.each do |m|
      @discussion.user_discussions.build(user: m, notify: true )
    end
  end

  def create
    @discussion = @project.discussions.new(discussion_params)
    @discussion.attachments_array=params[:attachments_array]

    if @discussion.save
      @discussion.create_activity :create, owner: current_user
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
    @discussion.attachments_array=params[:attachments_array]

    if @discussion.update(discussion_params.except!(:user_id))
      @discussion.create_activity :update, owner: current_user
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
    @project = Project.find(params[:project_id])
  end

  def discussion_params
    params.require(:discussion).permit(:title, :content, :project_id, :private, :discussion_group_id,
                                       discussion_group_attributes: [:name],
                                       user_discussions_attributes: [:id, :user_id, :notify, :_destroy ])
        .deep_merge(user_id: current_user.id, discussion_group_attributes: { project: @project, creator: current_user})

  end

  def build_user_discussions
    user_ids = @discussion.project.members.map(&:id) - @discussion.users.map(&:id)
    return if user_ids.blank?

    user_ids.each do |user_id|
      @discussion.user_discussions.build(user_id: user_id, notify: true )
    end
  end
end
