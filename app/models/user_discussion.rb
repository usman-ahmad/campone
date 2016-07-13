class UserDiscussion < ApplicationRecord
  belongs_to :user
  belongs_to :discussion

  validates :user, uniqueness: { scope: :discussion, message: "Already invited on this Discussion." }
end
