class Project < ActiveRecord::Base
  belongs_to :owner, class_name: 'User'
  belongs_to :project_group

  has_many :tasks
  has_many :discussions
  has_many :invitations
  has_many :members, through: :invitations, :source => :user
  has_many :events
  has_many :attachments

  validates :name, presence: true

  accepts_nested_attributes_for :project_group, :reject_if => proc { |attributes| attributes['name'].blank? }

  def create_attachments(array)
    return unless array.present?

    array.each do |file|
      attachments.build(:attachment => file)
    end

    save
  end
end
