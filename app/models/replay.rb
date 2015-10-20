class Replay < ActiveRecord::Base
  belongs_to :user
  belongs_to :comment
  validates :content, presence: true
end
