require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'name' do
    let(:discussion_group) {create(:discussion_group)}
    let(:project_group) {create(:project_group)}

    it 'name should be present' do
      build(:discussion_group, name:nil).should_not be_valid
    end

    context 'within type scope' do
      it 'should not allow us to create Groups of same name within same type' do
      build(:discussion_group, name:discussion_group.name).should_not be_valid
      end
    end
    context 'outside the type scope' do
      it 'should allow us to create Group with same name' do
        create(:project_group, name:discussion_group.name).should be_valid
      end
    end
  end
end
