require 'rails_helper'

RSpec.describe Task, type: :model do
  let(:user){ create(:user) }
  let(:project){ create(:project, owner: user) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:project) }

    it { should     allow_value("Completed").for(:progress) }
    it { should_not allow_value("blah")     .for(:progress) }

    it { should     allow_value("High").for(:priority) }
    it { should_not allow_value("blah").for(:priority) }
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:task_group) }

    it { should have_many(:comments) }
    it { should have_many(:attachments) }
  end


  describe 'filter_tasks' do
    # This is sample data used for testing Search and filter tasks,
    # Changing this data may break these specs. So dont change or Add/Remove this data.
    let!(:task)          { create(:task, title: 'task one', description: 'task 1 create ERD',   progress: 'Started',   creator: user, project: project) }
    let!(:completed_task){ create(:task, title: 'task two', description: 'task 2 create DB',    progress: 'Completed', creator: user, project: project) }
    let!(:another_task)  { create(:task, title: 'another ', description: 'another description', progress: 'Accepted',  creator: user, project: project) }

    it 'returns non-completed tasks meeting the search criteria' do
      tasks = Task.filter_tasks(search_text: 'task')

      expect(tasks.count).to eq 1
      expect(tasks.first.title).to eq 'task one'
    end

    it 'returns all non-completed tasks when no search text is given' do
      tasks = Task.filter_tasks(search_text: nil)
      expect(tasks.count).to eq 1
    end

    it 'returns ALL tasks (completed + non-completed)' do
      tasks = Task.filter_tasks(include_completed: true)
      expect(tasks.count).to eq 3
    end

    it 'includes completed tasks meeting search criteria' do
      tasks = Task.filter_tasks(search_text: 'task', include_completed: true)
      expect(tasks.count).to eq 2
    end

    describe '#search' do
      it 'searches by single word in description' do
        expect(Task.search('create').count).to eq 2
      end

      it 'searches by multiple words in description' do
        expect(Task.search('create create DB').count).to eq 1
      end

      it 'proves case-insensitive search' do
        expect(Task.search('CreaTE Erd').count).to eq 1
      end

      it 'returns unique records' do
        expect(Task.search('task').count).to eq 2
      end
    end
  end

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
