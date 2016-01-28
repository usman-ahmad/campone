class TwitterService


  def get_twitter_clients(project)
    integrations = project.integrations.twitter
    clients = []
    integrations.each do |integration|
      begin
        client = Twitter::REST::Client.new do |config|
          config.consumer_key = ENV['TWITTER_KEY']
          config.consumer_secret = ENV['TWITTER_SECRET']
          config.access_token = integration.token
          config.access_token_secret = integration.secret
        end
        clients << client
      end
    end
    clients
  end

  def self.message(activity)
    "From : CampOne
     Project : #{activity.project.name}
     #{activity.get_trackable.title}
     #{activity.discription}"
  end
end