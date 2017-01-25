class StoriesController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :story, :through => :project

  before_action :set_project
  before_action :set_story, only: [:show, :edit, :update, :destroy]

  # UA[2017/01/10] - WHAT ABOUT SORT AND IMPORT
  before_action :set_performer, only: [:create, :update, :destroy, :set_state, :assigned_to_me]

  def index
    cookies[:stories_visibility] = params[:visibility] || cookies[:stories_visibility]
    @visibility = cookies[:stories_visibility] || 'all'

    @story = @project.stories.new

    @stories = @project.stories.with_state(@visibility).search(params[:search_text]).order!('position')
    @stories = @stories.tagged_with(params[:tags]) if params[:tags].present?
    @stories = @stories.having_ownership(params[:owner]) if params[:owner].present?

    respond_to do |format|
      format.html
      # Export all Stories shown on index page in sequence. If You want to include completed stories you have to show them on index.
      format.csv { send_data @stories.to_csv }
    end
  end

  def show
    @commentable = @story
    @comments = @commentable.comments
    @comment = Comment.new
    @attachment = Attachment.new
  end

  def new
    @story = @project.stories.new
  end

  def create
    @story = @project.stories.new(story_params.merge(performer: current_user))
    # GS[2015/12/22] - TODO Refactor this, attr_accessor should do the trick
    @story.attachments_array = params[:attachments_array]

    # UA[2016/12/06] - MOVE THESE MODEL RELATED LOGIC TO AR_CALLBACKS
    if params[:add_files_to_project]
      @project.create_attachments(params[:attachments_array], current_user)
    end

    if @story.save
      # @story.create_activity :create, owner: current_user
      redirect_to [@project, :stories], notice: 'Story was successfully created.'
    else
      render :new
    end
  end

  def edit
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    if @story.update(story_params)
      # @story.create_activity :update, owner: current_user
      redirect_to [@project, @story], notice: 'Story was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @story.destroy
    redirect_to project_stories_url, notice: 'Story was successfully destroyed.'
  end

  def assigned_to_me
    if @story.update_attributes(owner_id: current_user.id)
      'Story is assigned to You'
    else
      'Story could not be assigned to You'
    end
    redirect_to [@project, @story]
  end

  def set_state
    if @story.update_attributes(state: params[:state])
      'State of story is updated successfully'
    else
      'State of story could not be updated'
    end
    redirect_to [@project, @story]
  end

  def sort
    params[:story].each_with_index do |id, index|
      Story.find(id).update_attributes(position: index+1)
    end

    # TODO: Sort in different groups
    render :nothing => true
  end

  def new_import
  end

  def import
    Story.import(params[:file], @project, current_user)
    redirect_to project_stories_path, notice: 'Stories imported.'
  end

  private

  def set_story
    @story = @project.stories.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def story_params
    params.require(:story).permit(:title, :description, :state, :project_id, :priority, :due_at, :owner_id, :tag_list, :story_type)
    # .merge(requester_id: current_user.id) # use performer in StoryController#set_performer ... Story#set_requester
  end

  def set_performer
    @story.performer = current_user
  end
end