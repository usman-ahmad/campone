class Vcsmessage
  # GS: class name should have same name as file, What about name of class to be VCSParser OR PayloadParser?
  attr_accessor :payload
  attr_accessor :event
  attr_accessor :vcs_name

  # Use this class to generate message of any event of any VCS
  #Example
  # Vcsmessage.new(Payload, "push","github" ).message

  # GS: A payload contains information about event_name and vcs_name, So why should we need to pas as arguments separately?
  def initialize(payload, event_name, vcs_name)
    @payload = payload
    @event = event_name
    @vcs_name = vcs_name
  end

  def message
    # GS:  I think we should create and return instance of subclass in constructor
    vcs_obj = @vcs_name.classify.constantize.new(@payload, @event)
    if vcs_obj.respond_to? @event
      vcs_obj.send event, @payload # No need to pas @payload class level variable as argument, it should be available in child class
    else
      raise NoMethodError.new("#{event} not implemented")
    end
  end
=begin
  This method will update task status (Performs any actions based on commit message)

  ### Example commit messages

  'fix #ticket_01'
  Des: will mark ticket_01 as completed, second form of verb can be used as action i-e fixes or fixed

  'fix #ticket_01 #ticket_02'
   Des: will mark both as completed you can use comman (,) colon (:) and samicolon (;) to perform action on multiple tickets

  'fixed #ticket_01 #ticket_02 and started #ticket_03'
  # will make ticket_01 and 02 as completed and ticket_03 as started. Yes! you can define multiple actions in one commit

  # all available actions are
  start|finish|complete|resolve|close|fix

  I know this function is scary but it works; will improve it later and more actions will be added
=end
  def perform_actions
    commits = get_commit_messages
    seperators = [',',':', ';', ' ']
    commits.each do |commit|

      matches = commit[:message].scan(/((start|finish|complete|resolve|close|fix)?e?s?d?\w?[\s,:;]#([-a-z0-9]+))/i)

      matches.each_with_index do |match,index|
        ticket_id = match[2]
        action    = match[1] || matches[index-1][2] if index > 0 and seperators.contains(match[0][0])

        task = Task.find(ticket_id.downcase)
        # Determine the action to take
        determine_and_take_actions!(action, task) if task
      end
    end
  end

  def determine_and_take_actions!(action, task)
    case action.downcase
      when 'start'
        # start the ticket

      when 'close', 'fix', 'reslove'
        # change status to finish
      when nil
        # create comment on referenced ticket
    end
  end

=begin
    Child classes should define this function and it should return array of commits (Array of hashes like given below)
    [
      { message: 'messge of commit 1', author: { email: 'author1@example.com', name: 'Foo Bar' } },
      { message: 'messge of commit 2', author: { email: 'author1@example.com', name: 'Don Joe' } }
    ]
=end
  def get_commit_messages
    raise 'Method Missing.'
  end
end