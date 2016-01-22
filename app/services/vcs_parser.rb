class VCSParser
  attr_accessor :payload
  attr_accessor :event
  attr_accessor :name

  # Use this class to generate message of any event of any VCS
  #Example
  # Vcsmessage.new(Payload, "push","github" ).message

  def initialize(payload)
    @payload = payload.info
    @event = payload.event
    name = payload.integration.name + 'Parser'
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
      CommitParser.perform_actions!(commit[:message])
    end
  end

=begin
    These functions are like abstract functions, This class dont know implementation, Child classes must define this function                                         ]

    Format of push event message
      {:head=>"2 new commits pushed by muhammad-ateek",
       :head_name => "username/repo_name"
       :head_url=>"HEAD_URL",
       :vcs_name =>"github",
       :commits=>[
           {
               :id=>"1c8...",
               :url=>"URL",
               :message=>"commit name - commiter name"},
           {
                :id=>"1803...",
                :url=>"URL",
                :message=>"second_commit_name - commiter name"
             }
         ]
       }
=end
  def push
    raise 'Method Missing'
  end

=begin
    It should return array of commits (Array of hashes like given below)
    [
      { message: 'message of commit 1', author: { email: 'author1@example.com', name: 'Foo Bar' } },
      { message: 'message of commit 2', author: { email: 'author1@example.com', name: 'Don Joe' } }
    ]
=end
  def get_commit_messages
    raise 'Method Missing.'
  end


  # Separating this class will make it easy to test
  class CommitParser
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
    def self.perform_actions!(commit)
      seperators = [',', ':', ';', ' ']
      # NoMethodError  (undefined method `scan' for #<Hash:0x0000000a2cc608>):
      # This method is raising an error. Priority : HIGH
      matches = commit.scan(/((start|finish|complete|resolve|close|fix)?e?s?d?\w?[\s,:;]+#([-a-z0-9]+))/i)

      matches.each_with_index do |match, index|
        ticket_id = match[2]
        action = match[1] || (matches[index-1][1] if index > 0 and seperators.include?(match[0][0]))

        task = Task.find(ticket_id.downcase)
        # Determine and perform action to take
        update_task!(task, action) if task
      end
    end

    def self.update_task!(task, action)
      case action.downcase
        when 'start'
          # start the ticket
          # TODO: Using string to match Progress are pron to typo errors. should use named constants
          task.update_attributes(progress: 'In progress') if task.progress == 'No progress'
        when 'close', 'fix', 'reslove'
          # change status to finish
          task.update_attributes(progress: 'Completed')
        when nil
          # create comment on referenced ticket?
      end
    end
  end
end