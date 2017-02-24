# == Schema Information
#
# Table name: stories
#
#  id                  :integer          not null, primary key
#  title               :string
#  description         :text
#  project_id          :integer
#  priority            :string
#  due_at              :date
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  state               :string           default("unscheduled")
#  owner_id            :integer
#  requester_id        :integer
#  position            :integer
#  ticket_id           :string
#  story_type          :string           default("feature")
#  requester_name      :string
#  closed_at           :datetime
#  closed_by_id        :integer
#  closed_by_user_name :string
#

class Story < ApplicationRecord
  include Notifiable
  act_as_notifiable performer: :performer,
                    receivers: :notification_receivers,
                    content_method: :title,
                    only: [:title, :description, :priority, :state, :owner_id],
                    # except: [:position, :updated_all]
                    on: [:create, :update, :destroy],
                    notifiable_integrations: Proc.new { |story| story.project.integrations.notifiable }

  # include PublicActivity::Common

  extend FriendlyId
  friendly_id :current_ticket_id, use: [:slugged, :finders], slug_column: :ticket_id
  alias_attribute :slug, :ticket_id

  # Acts As Taggable On uses scopes to create an association for tags. This way you can mix and match to filter down your results.
  acts_as_taggable_on :tags

  belongs_to :project
  belongs_to :requester, class_name: User, foreign_key: :requester_id
  belongs_to :owner, class_name: User, foreign_key: :owner_id

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  # TODO: User can still access story if he knows its tickect_id through URL, Need to introduce authorization
  scope :open, -> { where(closed_at: nil) }

  # shouldn't we add validation for presence of requester
  # validates :requester, presence: true
  # validates_format_of :tag_list, with: /\A[\w\-\,\s]+\z/, allow_blank: true, on: [:create, :update]
  validates :tag_list, tag_list: true, allow_blank: true

  before_create :set_position
  before_create :set_requester
  after_create :increment_ticket_counter

  STATE_MAP = {
      NOT_SCHEDULED: 'unscheduled',
      NO_PROGRESS: 'unstarted',
      IN_PROGRESS: 'started',
      PAUSED: 'paused',
      COMPLETED: 'finished',
      DEPLOYED: 'delivered',
      REJECTED: 'rejected',
      ACCEPTED: 'accepted',
      CLOSED: 'accepted'
  }

  # UA[2017/01/10] - Performer can be refactored in notifiable module
  attr_accessor :performer

  PRIORITIES =%w[Low Medium High]
  STORY_TYPES = %w(feature bug)
  STATES = %w[unscheduled unstarted started paused finished delivered rejected accepted]
  delegate :unscheduled?, :unstarted?, :started?, :paused?, :finished?, :delivered?, :rejected?, :accepted?,
           to: :current_state
  CURRENT_STATES = %w[unstarted started paused finished delivered rejected]

  validates :title, presence: true
  validates :project, presence: true
  validates :story_type, presence: true, inclusion: {in: STORY_TYPES}

  validates_inclusion_of :state, in: STATES
  validates_inclusion_of :priority, in: PRIORITIES, :allow_blank => true

  def notification_receivers
    project.members - [performer]
  end

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:document => file, project: self.project, uploader_id: self.requester_id)
    end
  end

  def current_state
    state.inquiry
  end

  def next_states
    case state
      when 'unscheduled'
        {schedule: 'unstarted', start: 'started'}
      when 'unstarted'
        {start: 'started'}
      when 'started'
        {pause: 'paused', finish: 'finished'}
      when 'paused'
        {resume: 'started'}
      when 'finished'
        {deliver: 'delivered'}
      when 'delivered'
        {accept: 'accepted', reject: 'rejected'}
      when 'rejected'
        {restart: 'started'}
      when 'accepted' # :accepted ~ :closed
        {}
      else
        {}
    end
  end

  def self.with_state(visibility_or_state)
    case visibility_or_state
      when 'current'
        where(state: CURRENT_STATES)
      when 'all'
        all
      else
        where(state: visibility_or_state)
    end
  end

  def self.having_ownership(owner)
    where(owner: owner)
  end

  def self.search(text)
    if text.present?
      where('title @@ :q or description @@ :q', q: text)
    else
      all
    end
  end

  def self.to_csv(options = {})
    csv_headers = ['title', 'description', 'priority', 'state', 'due_at']

    CSV.generate(options) do |csv|
      csv << csv_headers
      all.each do |story|
        attributes = story.attributes
        csv << attributes.values_at(*csv_headers)
      end
    end
  end

  def self.import(file, project, current_user)
    # TODO: Make it atomic
    CSV.foreach(file.path, headers: true) do |row|
      attributes = row.to_hash
      attributes['performer'] = current_user

      project.stories.create!(attributes)
    end
  end

  # copies a story into another project.
  # params
  # ======
  # => project: where you want to copy your story to
  # => mover: current_user moving this stories. User must have access to the above project
  # => options: with_comments(default: false), with_attachments(default: true)
  # Example: story.copy_to(project, user, with_attachments: false)
  # TODO: 1) Copy attachments of comments. 2) Provide an option to delete original story (like move). 3) Write specs
  # Implemented 1) Copy attachments of comments.
  # We may prefer to create a new class i-e StoryMover.new(story, project, mover, options).move!
  def copy_to(project, mover, options = {})
    return false if Ability.new(mover).cannot? :read, project

    default_options = {
        with_comments: false,
        with_attachments: true
    }
    options = default_options.merge(options)

    performer = project.members.include?(self.requester) ? self.requester : mover
    owner = project.members.include?(self.owner) ? self.owner : nil

    attrs = self.attributes.slice('title', 'description', 'priority', 'progress', 'due_at').merge!(performer: performer, owner: owner)
    story = project.stories.create(attrs)

    if options[:with_comments]
      self.comments.each do |c|
        new_comment= c.dup

        if project.members.include?(c.user)
          new_comment.performer = c.user
          story.comments << new_comment
        else
          # We may prefer to use dummy user names (User 1) instead of actual user name
          new_comment = Comment.new(performer: mover, content: "#{c.user.name} said: <br> #{c.content} <br><br>")
          story.comments << new_comment
        end

        c.attachments.each do |a|
          attachment = a.dup
          attachment.document = a.document
          new_comment.attachments << attachment
        end
      end
    end

    if options[:with_attachments]
      self.attachments.each do |a|
        attachment = a.dup
        attachment.document = a.document
        story.attachments << attachment
      end
    end

    story.save
    story
  end

  def get_tags
    self.tags.map(&:to_s)
  end

  def close
    update(closed_at: Time.current, closed_by_id: performer.id, closed_by_user_name: performer.name)
  end

  def get_source_tags
    p_tags = []

    self.project.stories.each do |story|
      p_tags = p_tags + story.owner_tags_on(nil, :tags).map { |t| t.name }
    end
    p_tags = p_tags.uniq
  end

  private

  def set_position
    self.position = self.project.stories.count + 1
  end

  def set_requester
    self.requester = performer
    self.requester_name = performer.name
  end

  def current_ticket_id
    [[project.friendly_id, project.reload.current_ticket_id]] if project
  end

  def increment_ticket_counter
    Project.increment_counter(:current_ticket_id, project)
  end
end
