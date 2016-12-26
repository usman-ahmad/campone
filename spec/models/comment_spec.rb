# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  content          :text
#  commentable_id   :integer
#  commentable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#

require 'rails_helper'

RSpec.describe Comment, type: :model do
  describe '#destroy' do
    let(:camp_project_owner) { create(:user) }
    let(:camp_project) { create(:project, title: 'chat project', owner: camp_project_owner) }
    let(:task_with_comments) { create(:task, :with_comments, comments_count: 3, reporter: camp_project_owner, project: camp_project) }
    let(:comment_with_real_attachments) { create(:comment, :with_attachments, attachments_count: 2, real_attachments: true, user: camp_project_owner, commentable: task_with_comments) }

    it 'deletes task having comments with attachments' do
      expect do
        comment_with_real_attachments
      end.to change { Comment.where(commentable: camp_project.tasks).count }.by(1)
                 .and change { Attachment.where(attachable: task_with_comments.comments).count }.by(2)

      path = task_with_comments.comments.last.attachments.first.document.path
      expect(File).to exist(path)

      expect do
        task_with_comments.destroy
      end.to change { camp_project.tasks.count }.by(-1)
                 .and change { Comment.where(commentable: camp_project.tasks).count }.by(-4)
                          .and change { Attachment.where(attachable: task_with_comments.comments).count }.by(-2)

      expect(File).not_to exist(path)
    end
  end
end
