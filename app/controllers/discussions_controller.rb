class DiscussionsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :discussion, :through => :project

  before_action :set_project
  before_action :set_discussion, only: [:show, :edit, :update, :destroy]
  before_action :build_user_discussions, only: [:edit]

  before_action :set_performer, only: [:update, :destroy]

  def index
    @discussions = @project.discussions

    @discussion = Discussion.new(project: @project)
    @discussion.attachments.build

    @project.members.each do |m|
      @discussion.user_discussions.build(user: m, notify: true)
    end
  end

  def show
    @commentable = @discussion
    @comments = @commentable.comments
    @comment = Comment.new
    @contributors = @discussion.private ? @discussion.users : @discussion.project.members
  end

  def new
    @discussion = @project.discussions.new
    @discussion.attachments.build

    @project.members.each do |m|
      @discussion.user_discussions.build(user: m, notify: true)
    end
  end

  def create
    @discussion = @project.discussions.new(discussion_params.merge(performer: current_user))
    @discussion.attachments_array = params[:attachments_array]
    @discussion.performer = current_user

    # UA[2016/12/06] - MOVE THESE MODEL RELATED LOGIC TO AR_CALLBACKS
    if params[:add_files_to_project]
      @project.create_attachments(params[:attachments_array], current_user)
    end

    respond_to do |format|
      if @discussion.save
        # @discussion.create_activity :create, owner: current_user
        format.html { redirect_to [@project, :discussions], notice: 'Discussion was successfully created.' }
        format.json { render json: @discussion, status: :created }
      else
        format.html { render :new }
        format.json { render json: @discussion.errors.full_messages, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    if @discussion.update(discussion_params)
      # @discussion.create_activity :update, owner: current_user
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
    params.require(:discussion).permit(:title, :content, :project_id, :private,
                                       user_discussions_attributes: [:id, :user_id, :notify, :_destroy])
  end

  def build_user_discussions
    user_ids = @discussion.project.members.map(&:id) - @discussion.users.map(&:id)
    return if user_ids.blank?

    user_ids.each do |user_id|
      @discussion.user_discussions.build(user_id: user_id, notify: true)
    end
  end

  def set_performer
    @discussion.performer = current_user
  end
end
