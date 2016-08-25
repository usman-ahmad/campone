require 'rails_helper'

# Custom matcher for matching Exported CSV data with expected results
RSpec::Matchers.define :have_value do |attribute, expected|
  match do |obj|
    if obj.is_a? Hash
      obj[attribute.to_s] == expected
    else
      obj.send(attribute)
    end
  end

  description do
    "have value '#{expected}' for '#{attribute}"
  end
end


RSpec.describe Task, type: :model do
  let(:user)   { create(:user) }
  let(:project){ create(:project, owner: user, name: 'T E S Ting') }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:project) }

    it { should     allow_value('No progress','Started','In progress','Completed',
                                'Rejected','Accepted','Deployed','Closed').for(:progress) }
    it { should_not allow_value("blah")     .for(:progress) }

    it { should     allow_value('None','Low','Medium','High').for(:priority) }
    it { should_not allow_value("blah").for(:priority) }
  end

  describe 'associations' do
    it { should belong_to(:project) }
    it { should belong_to(:creator) }

    it { should have_many(:comments) }
    it { should have_many(:attachments) }
  end


  describe 'default values' do
    expected_values = { progress: 'No progress', priority: 'None' }

    expected_values.each do |key,val|
      it { is_expected.to have_value(key, val) }
    end
  end

  describe 'callbacks' do
    let!(:task) { create(:task, title: 'task one', creator: user, project: project) }

    describe 'set_position' do
      it 'assigns first position' do
        expect(task.position).to eq 1
      end

      it 'assigns second position' do
        task = create(:task, title: 'task two', creator: user, project: project)
        expect(task.position).to eq 2
      end
      
      it 'assigns first position for first task of an other project' do
        another_project = create(:project, owner: user)
        task = create(:task, title: 'task three', creator: user, project: another_project)
        expect(task.position).to eq 1
      end
    end

    describe 'current_ticket_id' do
      it 'assigns correct ticket_id to task' do
        expect(task.ticket_id).to eq "test-1"
      end

      it 'increases current_ticket_id' do
        expect{ create(:task, project: project, creator: user) }.to change{ project.current_ticket_id }.by(1)
      end
    end
  end

    describe 'class level methods' do
    # This is sample data used for testing Search and CSV exports
    # Changing this data may break these specs. So dont change or Add/Remove this data.
    let!(:task)          { create(:task, title: 'task one', description: 'task 1 create ERD',   progress: 'Started',   creator: user, project: project) }
    let!(:completed_task){ create(:task, title: 'task two', description: 'task 2 create DB',    progress: 'Completed', creator: user, project: project) }
    let!(:another_task)  { create(:task, title: 'another ', description: 'another description', progress: 'Accepted',  creator: user, project: project) }

    describe '#filter_tasks' do
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

    describe 'CSV import/export' do
      let!(:task1) { create(:task, title: 'create psd', description: 'task one in group',
                                     progress: 'Started',   creator: user, project: project) }

      let!(:task2) { create(:task, title: 'create html templates', description: 'task two in group',
                                     progress: 'Rejected', priority: 'Medium', creator: user, project: project) }


      describe '#to_csv (export to CSV file)' do
        let!(:exported_string) { Task.all.to_csv }
        let!(:exported_array)  { CSV.parse(exported_string, headers: true) }
        let!(:exported_data)   { exported_array.map { |row| row.to_hash }  }


        it 'exports correct number of rows' do
          expect(exported_array.length).to eq 5
        end

        describe 'Exported Values' do
          subject! { exported_data.find{|d| d['title'] == 'create html templates'} }

          expected_values = {
              title: 'create html templates', description: 'task two in group',
              progress: 'Rejected', priority: 'Medium'
          }

          expected_values.each do |k,v|
            it { is_expected.to have_value k, v}
          end
        end
      end

      describe '#import (from CSV)' do
        let(:csv_file) { File.open Rails.root.join('spec', 'files', 'tasks.csv') }

        before { Task.import csv_file, project, user }

        it 'imports all records' do
          expect(Task.count).     to eq 8 # 5 existing and 3 newly created from CSV
        end

        describe 'imported task' do
          subject { Task.last }

          expected_values = {
              title: 'add authentication', description: 'use devise',
              progress: 'Started', priority: 'None'
          }

          expected_values.each do |k,v|
            it { is_expected.to have_value k, v}
          end
        end
      end
    end
  end

  describe '#assigned_to_me' do
    let(:another_user){ create(:user) }

    context 'assigned to nobody' do
      let!(:task) { create(:task, project: project, creator: user) }

      before { task.assigned_to_me(another_user) }
      it 'assigns task to a user' do
        expect(task.assigned_to).to eq another_user.id
      end
    end

    context 'already assigned' do
      let!(:task) { create(:task, project: project, creator: user, assigned_to: user.id) }

      before { task.assigned_to_me(another_user) }
      it 'will not assign task' do
        expect(task.assigned_to).to eq user.id
      end
    end

    context 'already in progress' do
      let!(:task) { create(:task, project: project, creator: user, assigned_to: user.id, progress: 'In progress') }

      before { task.assigned_to_me(another_user) }
      it 'will not assign task' do
        expect(task.assigned_to).to eq user.id
      end
    end
  end

  describe '#set_progress' do
    before { task.set_progress(user, 'In progress') }

    context 'Task is assigned to that user' do
      let!(:task) { create(:task, project: project, creator: user, assigned_to: user.id) }

      it 'will change progress' do
        expect(task.progress).to eq 'In progress'
      end
    end

    context 'Task is NOT assigned to that user' do
      let(:another_user){ create(:user) }
      let!(:task) { create(:task, project: project, creator: user, assigned_to: another_user.id) }

      it 'would NOT changes progress' do
        expect(task.progress).to eq 'No progress' # Default value
      end
    end
  end

  it 'should have title' do
    expect(build(:low_priority_task, project: project, commenter: project.owner, title:nil )).to_not be_valid
  end

  it 'should not allow due date in past', pending: 'Add validation in model if required.' do
    expect(build(:medium_priority_task, project: project, commenter: project.owner, due_at: (Date.today - 1) )).to_not be_valid
  end

  it 'should allow nil due date' do
    expect(build(:high_priority_task, project: project, commenter: project.owner, due_at: nil )).to be_valid
  end

  it 'should allow us to create' do

    expect(create(:low_priority_task,project: project, commenter: project.owner , creator: project.owner ).priority).to eq("Low")
    expect(create(:low_priority_task,project: project,progress: 'Completed', commenter: project.owner  , creator: project.owner).progress).to eq("Completed")
    expect(create(:medium_priority_task,project: project , commenter: project.owner , creator: project.owner).priority).to eq("Medium")
    expect(create(:high_priority_task,project: project,progress: 'No progress' , commenter: project.owner , creator: project.owner).priority).to eq("High")

  end

end
