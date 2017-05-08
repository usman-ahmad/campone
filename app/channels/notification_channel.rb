# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
# http://edgeguides.rubyonrails.org/action_cable_overview.html#connect-consumer
# https://github.com/rails/actioncable-examples
# https://github.com/jwo/inventory-cable
class NotificationChannel < ApplicationCable::Channel
  def subscribed
    # stream_for 'some_channel'
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def notify
    # ActionCable.server.broadcast('some_channel', message: data['message'], name: current_user.name)

    # sample notification
    NotificationChannel.broadcast_to(
        current_user,
        title: 'New things!',
        body: 'All the news fit to print'
    )
  end

end
