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

class Integration < ApplicationRecord
=begin
  we should consider Inheritance for different type of Integrations
  i-e Inbound/Outbound Notification, Import Integration etc
=end

  belongs_to :project
  has_many :payloads

  # TODO: Fix validations. Should we validate uniqueness of title
  # URL is not required for all integrations. We should consider inheritance
  # There should be way where can define required attributes for an integrations
  validates :url, presence: true
  validates :project_id, presence: true

  attr_accessor :performer

  # TODO DELETE NAME ATTRIBUTE
  # validates :name, presence: true

  AVAILABLE_INTEGRATIONS = %w[slack hipchat flowdock asana trello]
  NOTIFIABLE_INTEGRATIONS = %w[slack hipchat flowdock twitter]
  SOURCE_CODE_INTEGRATION = %w[bitbucket github]
  IMPORT_STORY_INTEGRATION = %w[asana trello jira]

  scope :slack_urls, -> { where(name: 'slack').map(&:url) }
  scope :hipchat_urls, -> { where(name: 'hipchat').map(&:url) }
  scope :flowdock_urls, -> { where(name: 'flowdock').map(&:url) }
  scope :twitter_accounts, -> { where(name: 'twitter') }

  # scope :notifiable, -> { where(name: %w[slack hipchat flowdock twitter]) }
  # NotifiableIntegration.all is same as below given notifiable scope
  # NotifiableIntegration.all.to_sql =>  "SELECT \"integrations\".* FROM \"integrations\" WHERE \"integrations\".\"type\" IN ('NotifiableIntegration', 'TwitterIntegration', 'SlackIntegration')"
  # But we must set `config.eager_load = true` in `config/environments/development.rb`
  scope :notifiable, -> { where(type: %w(SlackIntegration HipchatIntegration FlowdockIntegration TwitterIntegration)) }

  def name
    # we are using name to dynamically show images. We also have a name column which is useless as we have type now
    type.underscore.split('_').first rescue ''
  end

  def self.find_or_create_integration(auth)
    object = find_or_initialize_by(url: auth.info.urls.Twitter)
    object.update_attributes(token: auth.credentials.token, secret: auth.credentials.secret, name: auth.provider)
  end

  def self.create_with_omniauth(project, auth)
    # send(auth.provider.to_sym, auth)
    # Forward this to corresponding child class
    (auth[:provider].titleize+'Integration').constantize.create_with_omniauth(project, auth)
  end

  def self.twitter(auth)
    find_or_create_by(name: auth.provider, url: auth.info.urls.Twitter) do |integration|
      integration.token = auth.credentials.token
      integration.secret = auth.credentials.secret
    end
  end

  def self.jira(auth)
    # in case of JIRA an integration is created already
    integration = find_by(name: auth.provider, url: auth.extra.access_token.consumer.site)
    integration.update_attributes(token: auth.credentials.token, secret: auth.credentials.secret)
    integration
  end

end
