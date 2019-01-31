module StoriesHelper

  def assigned_to_options(project)
     project.members.collect { |m| [ m.name, m.id ] }
  end

  def story_assigned_to(story)
    case story.owner_id
      when nil
        'Nobody'
      else
        User.find(story.owner_id).name
    end
  end

  def story_created_time(time)
    distance_of_time_in_words(Time.current, time)
  end

  def initials(project, obj)
    user = obj.respond_to?(:requester) ? obj.requester : obj.user
    project.contributions.find_by_user_id(user).try(:initials) || user.name.split(' ').collect{|x| x[0]}.join()
  end

  def project_json(project)
    {
        members: project.members.map {|m| {id: m.id, name: m.name}},
        priorities: Story::PRIORITIES,
        story_types: Story::STORY_TYPES,
        states: Story::STATES
    }.to_json
  end
end
