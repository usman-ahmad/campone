module API
  module V1
    class Projects < Grape::API
      version 'v1'
      format :json
      resource :posts do
        desc "Return list of pojects"
        get do
          Project.all
        end
      end
    end
  end
end
