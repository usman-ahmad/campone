require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:user){ create(:user) }
  let(:project){ create(:project, owner: user) }

  describe "due_at date" do
    it 'should not allow due date in past' do
      expect(build(:event, project: project, due_at: (Date.today - 1) )).to_not be_valid
    end

    it 'should present due date' do
      expect(build(:event, project: project, due_at: nil )).to_not be_valid
    end
  end
  
  it 'should have title' do
    expect(build(:event, project: project, title:nil )).to_not be_valid
  end

  it 'should create event' do
    event = create(:event, project: project, title:'Project testing')
    expect(event.title).to eq ('Project testing')
    expect(event.due_at).to_not be < Date.today
  end
end
