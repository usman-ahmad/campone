class DiscussionSerializer < ActiveModel::Serializer
  attributes :id, :title, :content, :private
end
