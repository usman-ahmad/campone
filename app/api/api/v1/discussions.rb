module API
  module V1
    class Discussions < Grape::API
      version 'v1'
      format :json

      helpers do
        def project
          projects   = Project.where(owner: current_user) + Contribution.where(user: current_user).map(&:project)
          project    = projects.select { |project| project.id == params[:project_id].to_i  }
          project[0]
        end
      end

      resource:discucssions do
        desc "return discussions of project"
          get do
            project.discussions unless !project.present?
          end
        end

      resource:discucssion do
        desc "return a selected discussion of a project"
       params do
        requires :discussion_id, type: Integer
       end
        get do
           project.discussions.where(id:params[:discussion_id]).first unless !project.present?
        end
      end

      resource:create_discucssion do
        desc "create a new discussion on project"
        params do
         requires :title, type: String
         requires :content, type: String
         requires :private, type: Boolean
        end
        get do
          project.discussions.create(title:params[:title],content:params[:content],private:params[:private]) unless !project.present?
        end
      end

      end
    end
end
