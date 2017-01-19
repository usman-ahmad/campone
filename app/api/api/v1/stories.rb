module API
  module V1
    class Stories < Grape::API
      version 'v1'
      format :json

      helpers do
        def project
          projects   = Project.where(owner: current_user) + Contribution.where(user: current_user).map(&:project)
          project    = projects.select { |project| project.id == params[:project_id].to_i  }
          project[0]
        end
      end

      resource :stories do
        desc "Return list of stories related to a project"
        params do
          requires :project_id , type: Integer
        end
        get do
          if project.present?
             project.stories
          else
            "Project is not found"
          end
        end
      end

      resource :get_story do
        desc "Return story of a project"
        params do
          requires :project_id , type: Integer
          requires :story_id , type: Integer
        end
        get do
          if project.present?
            story     =  project.stories.where(id:params[:story_id]).first
            if story.present?
             story
            else
              "Story is not Present"
            end
          else
            "Project is not found"
          end
        end
      end

      resource :delete_story do
        desc "delete story of a project"
        params do
          requires :project_id , type: Integer
          requires :story_id , type: Integer
        end
        get do
          if project.present?
            story     =  project.stories.where(id:params[:story_id]).first
            if story.present?
              story.delete
              "Story deleted"
            else
              "Story is not Present"
            end
          else
            "Project is not found"
          end
        end
      end

    end
  end
end
