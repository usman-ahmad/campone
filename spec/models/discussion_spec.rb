require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:user){ create_list(:user, 3) }
  let(:project){ create(:project, owner: user.first) }

  describe 'title' do
    it 'should present' do
      build(:none_private_discussion,project: project, commenter: project.owner, title:nil ).should_not be_valid
    end
  end
  describe 'invite on discussion' do
    let(:discussion) {create(:private_discussion,project: project, commenter: project.owner)}

    it 'should share with users' do
      user.each do |user|
        FactoryGirl.create(:user_discussion, user: user, discussion: discussion)
      end
         discussion.users.count.should eq(3)
    end

  end
end
