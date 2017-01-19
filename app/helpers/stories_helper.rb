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
end
