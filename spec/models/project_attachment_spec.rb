# == Schema Information
#
# Table name: attachments
#
#  id                      :integer          not null, primary key
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  description             :text
#  attachable_id           :integer
#  attachable_type         :string
#  project_id              :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#  title                   :string
#

require 'rails_helper'

RSpec.describe ProjectAttachment, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }

  context 'validations' do
    it { should validate_presence_of :title }

    it 'should be valid attachment' do
      expect(build(:attachment, attachment: File.new('spec/files/awesome_project_attachment.jpg'), project: project)).to be_valid
    end
  end
end
