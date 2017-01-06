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
#

class Integration < ApplicationRecord
=begin
  we should consider Inheritance for different type of Integrations
  i-e Inbound/Outbound Notification, Import Integration etc
=end

  belongs_to :project
  has_many :payloads

  # URL is not required for all integrations. We should consider inheritance
  # There should be way where can define required attributes for an integrations
  validates :url, presence: true
  validates :project_id, presence: true
  validates :name, presence: true

  scope :slack_urls, -> { where(name: 'slack').map(&:url) }
  scope :hipchat_urls, -> { where(name: 'hipchat').map(&:url) }
  scope :flowdock_urls, -> { where(name: 'flowdock').map(&:url) }
  scope :twitter_accounts, -> { where(name: 'twitter') }

  scope :notifiable, -> { where(name: %w[slack hipchat flowdock twitter]) }

  def self.find_or_create_integration(auth)
    object = find_or_initialize_by(url: auth.info.urls.Twitter)
    object.update_attributes(token: auth.credentials.token, secret: auth.credentials.secret, name: auth.provider)
  end

  def self.create_with_omniauth(auth)
    send(auth.provider.to_sym, auth)
  end

  def self.twitter(auth)
    find_or_create_by(name: auth.provider, url: auth.info.urls.Twitter) do |integration|
      integration.token = auth.credentials.token
      integration.secret = auth.credentials.secret
    end
  end

  def self.asana(auth)
    # puts auth.pretty_inspect
    find_or_create_by(name: auth.provider, url: 'https://app.asana.com/'+ auth.info.name) do |integration|
      integration.token = auth.credentials.refresh_token
    end
  end

  def self.jira(auth)
    # in case of JIRA an integration is created already
    integration = find_by(name: auth.provider, url: auth.extra.access_token.consumer.site)
    integration.update_attributes(token: auth.credentials.token, secret: auth.credentials.secret)
    integration
  end

  def self.trello(auth)
    find_or_create_by(name: auth.provider, url: auth.info.urls.profile) do |integration|
      integration.token = auth.credentials.token
      integration.secret = auth.credentials.secret
    end
  end
end
