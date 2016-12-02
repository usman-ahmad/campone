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

require 'rails_helper'

RSpec.describe UserDiscussion, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
