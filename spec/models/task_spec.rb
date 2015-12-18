require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user){ create(:user) }
  let(:project){ create(:project, owner: user) }

  it 'should have title' do
    build(:low_priority_task, project: project, commenter: project.owner, title:nil ).should_not be_valid
  end

  it 'should not allow due date in past' do
    build(:medium_priority_task, project: project, commenter: project.owner, due_at: (Date.today - 1) ).should_not be_valid
  end

  it 'should present due date' do
    build(:high_priority_task, project: project, commenter: project.owner, due_at: nil ).should_not be_valid
  end

  it 'should allow us to create' do

    create(:low_priority_task,project: project, commenter: project.owner ).priority.should eq("low")
    create(:low_priority_task,project: project,progress: :completed, commenter: project.owner ).progress.should eq("completed")
    create(:medium_priority_task,project: project , commenter: project.owner).priority.should eq("medium")
    create(:high_priority_task,project: project,progress: :no_progress , commenter: project.owner).priority.should eq("high")

  end

end
