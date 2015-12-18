require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user){ create(:user) }
  let(:project){ create(:project, owner: user) }

  describe "due_at date" do
    it 'should not allow due date in past' do
      build(:event, project: project, due_at: (Date.today - 1) ).should_not be_valid
    end

    it 'should present due date' do
      build(:event, project: project, due_at: nil ).should_not be_valid
    end
  end
  
  it 'should have title' do
    build(:event, project: project, title:nil ).should_not be_valid
  end

  it 'should create event' do
    event = create(:event, project: project, title:'Project testing')
    event.title.should eq ('Project testing')
    event.due_at.should_not be < Date.today
  end
end
