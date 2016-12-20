# == Schema Information
#
# Table name: projects
#
#  id                :integer          not null, primary key
#  title             :string
#  description       :text
#  owner_id          :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  slug              :string
#  current_ticket_id :integer          default(1)
#

require 'rails_helper'

RSpec.describe Project, type: :model do
  let!(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:owner) }
  end

  describe 'associations' do
    it { should belong_to(:owner) }
    it { should have_many(:tasks) }
    it { should have_many(:discussions) }
    it { should have_many(:contributions) }
    it { should have_many(:members) }
    it { should have_many(:attachments) }
    it { should have_many(:events) }
    it { should have_many(:integrations) }

    it 'adds owner to contributors' do
      expect { create(:project, owner: user) }.to change { Contribution.count }.by(1)
    end

    it 'assigns owner role to contribution' do
      expect(project.contributions.where(role: 'Owner').count).to eq 1
    end
  end

  describe 'slug' do
    let!(:project) { create(:project, owner: user, title: 'T E S Ting') }

    it 'should create a slugged ID containing initials of project title' do
      expect(project.slug).to match /test/
    end

    # TODO: Confirm this is expected behavior
    # If we wanna change slug we can enable History option of friendly_id gem
    # Old links may be pointing to url with old slug, we may have to change ticket_ids as well
    it 'should NOT update slug on changing project title' do
      project.update_attributes title: 'New Title'
      expect(project.slug).to match /test/
    end

    context 'for already existing slug' do
      before do
        rand = double(bool: false)
        # returns the specified values in order, then keeps returning the last value
        allow(rand).to receive(:generate).and_return(1, 2)
        allow_any_instance_of(Project).to receive(:slug_candidates).and_return(-> { ['test', ['test', rand.generate]] })
      end

      let!(:project_2) { create(:project, owner: user, title: 'T E S Ting') }
      let!(:project_3) { create(:project, owner: user, title: 'T E S Ting') }

      it 'tries new slug' do
        expect(project_2.slug).to match /test-1/
        expect(project_3.slug).to match /test-2/
      end
    end
  end

  it 'should have owner' do
    expect(project.owner).to eq(user)
  end

  # This seems to be more like validations of factories
  describe 'associations' do
    context 'when associated with tasks' do
      let(:project_with_single_task) { create(:project, :with_tasks, task_owner: user, task_count: 1) }
      let(:project_with_many_tasks) { create(:project, :with_tasks, task_owner: user, task_count: 5) }

      it 'should have single task' do
        expect(project_with_single_task.tasks.count).to eq(1)
      end

      it 'should have many task' do
        expect(project_with_many_tasks.tasks.count).to eq(5)
      end
    end

    context 'when associated with Discussions' do
      let(:project_with_discussions) { create(:project, :with_discussions, discussion_owner: user, discussion_count: 2) }

      # let(:project_with_task_discussions) {create(:project_with_task_discussions, owner: user)}

      it 'should have discussions' do
        expect(project_with_discussions.discussions.count).to eq(2)
      end

      # it 'should have task and discussion at a time' do
      #   expect(project_with_task_discussions.tasks.count).to eq(1)
      #   expect(project_with_task_discussions.discussions.count).to eq(1)
      #
      # end
    end
  end

end
