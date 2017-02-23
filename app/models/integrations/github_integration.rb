# == Schema Information
#
# Table name: integrations
#
#  id         :integer          not null, primary key
#  project_id :integer
#  url        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  name       :string
#  token      :string
#  secret     :string
#  type       :string
#  title      :string
#  active     :boolean
#

class GithubIntegration < SourceCodeIntegrations
  has_many :payloads, class_name: GithubPayload, foreign_key: :integration_id
end
