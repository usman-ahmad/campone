# == Schema Information
#
# Table name: discussions
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  private    :boolean
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  opener_id  :integer
#

class Discussion < ApplicationRecord
  # include Attachable
  include Notifiable
  # include PublicActivity::Common

  include Notifiable
  act_as_notifiable performer: :performer,
                    receivers: :notification_receivers,
                    content_method: :title,
                    only: [:title, :content, :private],
                    notifiable_integrations: Proc.new { |discussion| discussion.project.integrations.notifiable }

  belongs_to :project
  belongs_to :opener, class_name: User, foreign_key: :opener_id

  has_many :user_discussions, dependent: :destroy
  has_many :users, through: :user_discussions

  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy

  validates :title, presence: true

  accepts_nested_attributes_for :user_discussions, :allow_destroy => true

  attr_accessor :performer

  before_create :set_opener

  def attachments_array=(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:document => file, project: self.project, uploader_id: self.opener_id)
    end
  end

  def last_activity
    # last_comment_activity = PublicActivity::Activity.where(trackable_id: comments.last.id, trackable_type: "Comment").last if comments.last.present?
    # last_disc_activity = activities.last if activities.last.present?
    # return last_comment_activity = last_comment_activity.created_at > last_disc_activity.created_at ? last_comment_activity : last_disc_activity unless !(last_comment_activity.present? && last_disc_activity.present?)
    # return last_disc_activity

    # TODO: Fix, for now returning last activity on discussion, we should also check comments
    # what about, if we touch commentable while creating comment
    notifications.order(created_at: :asc).last
  end

  def notification_performer
    opener
  end


  # TODO: Add specs
  # other_contributors; except opener (who started this discussion)
  def other_contributors
    (private ? users : project.members) - [opener]
  end

  private

  def set_opener
    self.opener = performer
  end

  def notification_receivers
    # TODO: Fix current user
    (private ? users : project.members) - [performer]
  end
end
