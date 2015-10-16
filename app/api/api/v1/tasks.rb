module API
  module V1
    class Tasks < Grape::API
      version 'v1'
      format :json

      resource :tasks do
        desc "Return list of tasks"
        params do
          requires :id , type: Integer
        end
        get do
           projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
           project    =  projects.select { |project| project.id == params[:id] }
          if project.present?
            project[0].tasks
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
          projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
          project    =  projects.select { |project| project.id == params[:project_id] }
          if project.present?
            task     =  project[0].tasks.select {|task| task.id == params[:task_id]}
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
          projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
          project    =  projects.select { |project| project.id == params[:project_id] }
          if project.present?
            task     =  project[0].tasks.select {|task| task.id == params[:task_id]}
            if task.present?
              task[0].delete
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
