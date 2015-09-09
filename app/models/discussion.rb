class Discussion < ActiveRecord::Base
  belongs_to :project
  belongs_to :discussion_group

  has_many :user_discussions
  has_many :users ,through: :user_discussions

  has_many :comments,    as: :commentable
  has_many :attachments, as: :attachable

  validates :title, presence: true

  accepts_nested_attributes_for :user_discussions ,:allow_destroy => true
  accepts_nested_attributes_for :discussion_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  def attachments_array=(array)
    array.each do |file|
      attachments.build(:attachment => file, project: self.project)
    end
  end
end
