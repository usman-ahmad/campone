require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'name' do
    let(:discussion_group) {create(:discussion_group)}
    let(:project_group) {create(:project_group)}

    it 'name should be present' do
      build(:discussion_group, name:nil).should_not be_valid
    end
  end
end
