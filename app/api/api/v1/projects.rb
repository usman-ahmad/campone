module API
  module V1
    class Projects < Grape::API
      version 'v1'
      format :json

      before do
        error!("401 Unauthorized", 401) unless authenticated
      end

      resource :posts do
        desc "Return list of pojects"
        get do
          Project.all
        end
      end
    end
  end
end
