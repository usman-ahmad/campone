# == Schema Information
#
# Table name: user_discussions
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  discussion_id :integer
#  notify        :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class UserDiscussion < ApplicationRecord
  belongs_to :user
  belongs_to :discussion

  validates :user, uniqueness: { scope: :discussion, message: "Already invited on this Discussion." }
end
