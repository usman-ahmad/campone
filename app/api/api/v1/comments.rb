module API
  module V1
    class Comments < Grape::API
      version 'v1'
      format :json

      helpers do
        def project
          projects   = Project.where(owner: current_user) + Invitation.where(user: current_user).map(&:project)
          projects.select { |project| project.id == params[:project_id] }
        end

        def commentable
          klass = [Task, Discussion].detect { |c| params["#{c.name.underscore}_id"] }
          @commentable = klass.where(id:params["#{klass.name.underscore}_id"], project_id:project).first
        end
      end

      resource :get_comments do
        desc "Return Comments of a task or discussionthat is related to a specific project"
        params do
          requires :project_id , type: Integer
        end
        get do
          if project.present?
             if commentable.present?
                commentable.comments
             else
              "Task or Discussion is not present to show comments"
            end
          else
            "Project is not found"
          end
        end
      end

      resource :post_new_comments do
        desc "post a new Comment on task or discussion that is related to a specific project"
        params do
          requires :project_id , type: Integer
          requires :comment , type: String
        end
        post do
          if project.present?
            if commentable.present?
              commentable.comments.create(content:params[:comment],user:current_user)
            else
              "Task or Discussion is not present to show comments"
            end
          else
            "Project is not found"
          end
        end
      end


    end
  end
end
