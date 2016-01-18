class VcsMessages
  attr_accessor :payload
  attr_accessor :event

  def initialize(payload, event_name)
    @payload = payload
    @event = event_name
    if self.respond_to? @event
       self.send event, @payload
    else
      raise NoMethodError.new("#{event} not implemented")
    end
  end

  def push(payload)
   #Generate Message
  end

end