class Notification < ActiveRecord::Base
  belongs_to :activity, :class_name => "PublicActivity::Activity"
  belongs_to :user

  enum status: [:unread, :read]

  before_save { self.status = :unread }
end
