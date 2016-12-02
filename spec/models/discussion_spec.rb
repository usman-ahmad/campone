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

require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:user){ create_list(:user, 3) }
  let(:project){ create(:project, owner: user.first) }

  describe 'title' do
    it 'should present' do
      expect(build(:none_private_discussion,project: project, commenter: project.owner, title:nil , user: project.owner)).to_not be_valid
    end
  end
  describe 'invite on discussion' do
    let(:discussion) {create(:private_discussion,project: project, commenter: project.owner, user: project.owner)}

    it 'should share with users' do
      user.each do |user|
        FactoryGirl.create(:user_discussion, user: user, discussion: discussion)
      end
      expect(discussion.users.count).to eq(3)
    end

  end
end
