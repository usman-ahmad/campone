require 'tracker_api'

class TrackerImport < ImportService
  attr_reader :client

  def set_client
    @client = TrackerApi::Client.new(token: @integration.token)
  end

  def import!(external_project_id)
    project  = @client.project(external_project_id)

    # Use Background Job here
    project.stories.each do |story|
      import_story(story)
    end
  end

  def import_story(story)
    # TODO: Manage Attachments and grouping
    attributes = {
        title: story.name,
        description: story.description,
        due_at: story.deadline,
        updated_at: story.updated_at,
        progress: map_progress(story.current_state),
    }

    @project.tasks.create(attributes)
  end


  def project_list
    projects = []

    client.projects.each do |p|
      projects << { title: p.title, id: p.id }
    end

    projects
  end

  private

  def map_progress(progress)
    # planned is mapped to NO_PROGRESS or unstarted
    case progress
      when 'unscheduled'
        Task::PROGRESS_MAP[:NOT_SCHEDULED]
      when 'unstarted'
        Task::PROGRESS_MAP[:NO_PROGRESS]
      when 'started'
        Task::PROGRESS_MAP[:IN_PROGRESS]
      when 'finished'
        Task::PROGRESS_MAP[:COMPLETED]
      when 'delivered'
        Task::PROGRESS_MAP[:DEPLOYED]
      when 'rejected'
        Task::PROGRESS_MAP[:REJECTED]
      when 'accepted'
        Task::PROGRESS_MAP[:ACCEPTED]
      else
        Task::PROGRESSES[:NO_PROGRESS]
    end
  end

end
