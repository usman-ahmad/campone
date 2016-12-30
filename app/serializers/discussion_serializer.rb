# == Schema Information
#
# Table name: discussions
#
#  id         :integer          not null, primary key
#  title      :string
#  content    :text
#  private    :boolean
#  project_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  opener_id  :integer
#

class DiscussionSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :private
end
