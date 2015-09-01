class Discussion < ActiveRecord::Base
  belongs_to :project
  has_many :user_discussions
  has_many :users ,through: :user_discussions
  has_many :comments, as: :commentable
  
  accepts_nested_attributes_for :user_discussions ,:allow_destroy => true
end
