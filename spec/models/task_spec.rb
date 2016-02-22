require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user){ create(:user) }
  let(:project){ create(:project, owner: user) }

  it 'should have title' do
    build(:low_priority_task, project: project, commenter: project.owner, title:nil ).should_not be_valid
  end

  it 'should not allow due date in past', pending: 'Add validation in model if required.' do
    build(:medium_priority_task, project: project, commenter: project.owner, due_at: (Date.today - 1) ).should_not be_valid
  end

  it 'should allow nil due date' do
    build(:high_priority_task, project: project, commenter: project.owner, due_at: nil ).should be_valid
  end

  it 'should allow us to create' do

    create(:low_priority_task,project: project, commenter: project.owner , creator: project.owner ).priority.should eq("Low")
    create(:low_priority_task,project: project,progress: 'Completed', commenter: project.owner  , creator: project.owner).progress.should eq("Completed")
    create(:medium_priority_task,project: project , commenter: project.owner , creator: project.owner).priority.should eq("Medium")
    create(:high_priority_task,project: project,progress: 'No progress' , commenter: project.owner , creator: project.owner).priority.should eq("High")

  end

end
