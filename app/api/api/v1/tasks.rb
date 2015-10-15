module API
  module V1
    class Tasks < Grape::API
      version 'v1'
      format :json

      before do
        error!("401 Unauthorized", 401) unless authenticated
      end

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

    end
  end
end
