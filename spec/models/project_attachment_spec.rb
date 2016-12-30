# == Schema Information
#
# Table name: attachments
#
#  id                    :integer          not null, primary key
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :integer
#  document_updated_at   :datetime
#  description           :text
#  attachable_id         :integer
#  attachable_type       :string
#  project_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  uploader_id           :integer
#  title                 :string
#  type                  :string
#

require 'rails_helper'

RSpec.describe ProjectAttachment, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, owner: user) }

  context 'validations' do
    it { should validate_presence_of :title }

    it 'should be valid attachment' do
      expect(build(:project_attachment, document: File.new('spec/files/awesome_project_attachment.jpg'), attachable: project)).to be_valid
    end

    describe '#destroy' do
      let(:camp_project_owner) { create(:user) }
      let(:camp_project) { create(:project, title: 'US project', owner: camp_project_owner) }
      let(:project_attachment) { create(:project_attachment, :with_real_attachment, :with_comments, comments_count: 4, commenter: camp_project_owner, attachable: camp_project) }

      it 'deletes attachment with comments' do
        expect do
          project_attachment
        end.to change { camp_project.attachments.count }.by(1)
                   .and change { Comment.where(commentable: camp_project.attachments).count }.by(4)

        path = camp_project.attachments.first.document.path
        expect(File).to exist(path)

        expect do
          project_attachment.destroy
        end.to change { camp_project.attachments.count }.by(-1)
                   .and change { Comment.where(commentable: camp_project.attachments).count }.by(-4)

        expect(File).not_to exist(path)
      end
    end
  end
end
