class Vcsmessage
  attr_accessor :payload
  attr_accessor :event
  attr_accessor :vcs_name

  # Use this class to generate message of any event of any VCS
  #Example
  # Vcsmessage.new(Payload, "push","github" ).message

  def initialize(payload, event_name, vcs_name)
    @payload = payload
    @event = event_name
    @vcs_name = vcs_name
  end

  def message
      vcs_obj = @vcs_name.classify.constantize.new(@payload, @event)
      if vcs_obj.respond_to? @event
        vcs_obj.send event, @payload
      else
        raise NoMethodError.new("#{event} not implemented")
      end
    end
end