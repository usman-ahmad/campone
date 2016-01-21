class VCSParser
  attr_accessor :payload
  attr_accessor :event
  attr_accessor :vcs_name

  # Use this class to generate message of any event of any VCS
  #Example
  # Vcsmessage.new(Payload, "push","github" ).message

  def initialize(payload)
    @payload  = payload.info
    @event    = payload.event
    @vcs_name = payload.integration.vcs_name + 'Parser'
  end

  def message
    if respond_to? @event
       send event
    else
      raise NoMethodError.new("#{event} not implemented")
    end
  end

    def push_actions
    commits = get_commit_messages
    commits.each do |commit|
      commit_actions(commit)
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
  def commit_actions(commit)
    seperators = [',',':', ';', ' ']

    commit = { message: 'fixed #ticket_01 #ticket_02 and started #ticket_03' }
    matches = commit[:message].scan(/((start|finish|complete|resolve|close|fix)?e?s?d?\w?[\s,:;]+#([-a-z0-9]+))/i)

    matches.each_with_index do |match,index|
      ticket_id = match[2]
      action    = match[1] || matches[index-1][2] if index > 0 and seperators.contains(match[0][0])

      task = Task.find(ticket_id.downcase)
      # Determine and perform action to take
      task_action(action, task) if task
    end
  end

  def task_action(action, task)
    case action.downcase
      when 'start'
        # start the ticket
        # TODO: Using string in Progress are pron to typo errors. should be named constants
        task.update_attributes(progress: 'In progress')
      when 'close', 'fix', 'reslove'
        # change status to finish
        task.update_attributes(progress: 'Completed')
      when nil
        # create comment on referenced ticket?
    end
  end
end