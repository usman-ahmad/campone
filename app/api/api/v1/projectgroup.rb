module API
  module V1
    class Projectgroup < Grape::API
      version 'v1'
      format :json

      resource :project_groups do
        desc "Return list of Groups"
        get do
          ProjectGroup.all
        end
      end

      resource :create_project_group do
        desc "Create a Project Group"
        params do
          requires :name, type: String
          requires :type, type:String
        end
        post do
         project = ProjectGroup.create(name:params[:name], type:params[:type])
        end
      end

    end
  end
end
