require 'rails_helper'

RSpec.describe Project, type: :model do
   let(:user){ create(:user) }
   let(:project){ create(:project, owner: user) }

   describe 'validations' do
     it { should validate_presence_of(:name) }
     it { should validate_presence_of(:owner) }
   end

   describe 'associations' do
     it { should have_many(:tasks) }
     it { should have_many(:discussions) }
     it { should have_many(:contributions) }
     it { should have_many(:attachments) }

     it 'adds owner to contributors' do
       expect{ create(:project) }.to change{ Contribution.count }.by(1)
     end

     it 'assigns owner role to contribution' do
       expect(project.contributions.owner.count).to eq 1
     end
   end

   it 'should have owner' do
      project.owner.should eq(user)
   end

   it 'should not allow without owner' do
     build(:project, owner: nil, name:nil).should_not be_valid
   end

   it 'validated project name is present' do
     build(:project, owner: user, name:nil).should_not be_valid
   end

   it 'validated project name is not duplicate' do
      project_name = project.name
      build(:project, owner: user, name:project_name).should be_valid
   end

   describe 'associations' do
    context 'when associated with tasks' do
      let(:project_with_single_task){ create(:project_with_single_task,owner: user) }
      let(:project_with_many_tasks){  create(:project_with_many_tasks,owner: user) }

      it 'sould have single task' do
        project_with_single_task.tasks.count.should eq(1)
      end

      it 'sould have many task' do
        project_with_many_tasks.tasks.count.should eq(6)
      end
    end

    context 'when associated with Discussions' do
      let(:project_with_discussions) {create(:project_with_discussions, owner: user)}
      let(:project_with_task_discussions) {create(:project_with_task_discussions, owner: user)}

      it 'should have discussions' do
        project_with_discussions.discussions.count.should eq(2)
      end

      it 'should have task and discussion at a time' do
        project_with_task_discussions.tasks.count.should eq(1)
        project_with_task_discussions.discussions.count.should eq(1)

      end
    end
   end

end
