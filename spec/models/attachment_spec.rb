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

RSpec.describe Attachment, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }
  let(:attachment) { create(:attachment, attachable_id: project.id, project: project,
                            attachment: File.new('spec/files/awesome_project_attachment.jpg')) }

  describe 'associations' do
    it { should belong_to :project }
    it { should belong_to :uploader }
    it { should belong_to(:attachable) }
  end

  describe 'validations' do

    it { should validate_presence_of :attachment }

    it 'is not valid without an attachment' do
      attachment = Attachment.new(attachment: nil)
      expect(attachment).to_not be_valid
    end
  end

  it 'is an instance of Attachment' do
    expect(attachment).to be_an Attachment
  end

  # TODO: To be confirm
  # it 'has a valid factory' do
  #   create(:attachment, attachment: File.new('spec/files/awesome_project_attachment.jpg')).should be_valid
  # end

  it 'increment attachments count' do
    expect { create(:attachment, attachment: File.new('spec/files/awesome_project_attachment.jpg')) }.to change { Attachment.count }.by(1)
  end

  it 'should have project' do
    expect(attachment.project).to eq(project)
  end

  describe '#is_image?' do
    it 'should be an image' do
      expect(attachment.is_image?).to be_truthy
    end

    it 'should be not image' do
      expect(attachment.is_video?).to be_falsey
    end
  end
end
