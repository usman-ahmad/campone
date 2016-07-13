class Notification < ApplicationRecord
  belongs_to :activity, :class_name => "PublicActivity::Activity"
  belongs_to :user

  enum status: [:unread, :read]

  before_create { self.status = :unread }
end
