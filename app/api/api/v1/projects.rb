module API
  module V1
    class Projects < Grape::API
      version 'v1'
      format :json

      resource :projects do
        desc "Return list of pojects"
        get do
          @projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
        end
      end

      resource :project do
        desc "Return a poject"
        params do
          requires :project_id , type: Integer
        end
        get do
          projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
           project = projects.select { |project| project.id == params[:project_id].to_i } unless !projects.present?
        end
      end

      resource :create_project do
        desc "create a new project"
        params do
          requires :name, type: String
          requires :description, type:String
          requires :project_group_id, type:Integer
        end
        post do
         current_user.projects.create(name:params[:name],description:params[:description],project_group_id:params[:project_group_id])
        end
      end

      resource :delete_project do
        desc "delete a project"
        params do
           requires :id, type:Integer
        end
        delete do
          project =  Project.where(id: params[:id],owner: current_user)
          if project.present?
             project.first.delete
          elsif !project.present?
            invitation = Invitation.where(user: current_user, project_id:params[:id])
            if invitation.present?
               invitation.first.delete
            else
              "Project invitation not found to delete"
            end
          else
            "Project not found to delete"
          end
        end
      end

    end
  end
end
