# == Schema Information
#
# Table name: contributions
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  token      :string
#  status     :string           default("pending")
#  inviter_id :integer
#  position   :integer
#  initials   :string
#

require 'rails_helper'

RSpec.describe Contribution, type: :model do
  let(:project) { FactoryGirl.create(:project) }
  subject { FactoryGirl.create(:contribution, project: project) }

  context 'validations' do
    it { is_expected.to validate_uniqueness_of(:initials).scoped_to(:project_id).case_insensitive }
  end

  describe '#set_initials' do
    let(:project) { FactoryGirl.create(:project) }
    let(:user) { FactoryGirl.create(:user, name: 'john doe') }
    let(:user2) { FactoryGirl.create(:user, name: 'john dee') }
    let!(:contribution1) { FactoryGirl.create(:contribution, project: project, initials: 'JD') }
    let(:contribution2) { FactoryGirl.create(:contribution, project: project, user: user) }
    let(:contribution3) { FactoryGirl.create(:contribution, project: project, user: user2) }

    it 'assigns proper initials' do
      expect(contribution2.initials).to eq 'JD1'
      expect(contribution3.initials).to eq 'JD2'
    end
  end

end
