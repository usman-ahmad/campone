module API
  module V1
    class Tasks < Grape::API
      version 'v1'
      format :json

      helpers do
        def project
          projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
          project    = projects.select { |project| project.id == params[:project_id].to_i  }
          project[0]
        end
      end

      resource :tasks do
        desc "Return list of tasks related to a project"
        params do
          requires :project_id , type: Integer
        end
        get do
          if project.present?
             project.tasks
          else
            "Project is not found"
          end
        end
      end

      resource :get_task do
        desc "Return task of a project"
        params do
          requires :project_id , type: Integer
          requires :task_id , type: Integer
        end
        get do
          if project.present?
            task     =  project.tasks.where(id:params[:task_id]).first
            if task.present?
             task
            else
              "Task is not Present"
            end
          else
            "Project is not found"
          end
        end
      end

      resource :delete_task do
        desc "delete task of a project"
        params do
          requires :project_id , type: Integer
          requires :task_id , type: Integer
        end
        get do
          if project.present?
            task     =  project.tasks.where(id:params[:task_id]).first
            if task.present?
              task.delete
              "Task deleted"
            else
              "Task is not Present"
            end
          else
            "Project is not found"
          end
        end
      end

    end
  end
end
