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
#  user_id    :integer
#

class Discussion < ApplicationRecord
  include Attachable
  include PublicActivity::Common

  belongs_to :project
  belongs_to :opener, class_name: User, foreign_key: :user_id

  has_many :user_discussions
  has_many :users ,through: :user_discussions

  has_many :comments,    as: :commentable
  has_many :attachments, as: :attachable

  validates :title, presence: true

  accepts_nested_attributes_for :user_discussions ,:allow_destroy => true

   def last_activity
      last_comment_activity  =  PublicActivity::Activity.where(trackable_id: comments.last.id, trackable_type: "Comment").last if  comments.last.present?
      last_disc_activity     =  activities.last if activities.last.present?
     return last_comment_activity   =  last_comment_activity.created_at > last_disc_activity.created_at ? last_comment_activity : last_disc_activity unless !(last_comment_activity.present? && last_disc_activity.present?)
     return last_disc_activity
   end

  def other_contributors
     private ? users : (project.members - [opener])
  end

end
