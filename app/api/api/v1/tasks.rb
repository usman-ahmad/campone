module API
  module V1
    class Tasks < Grape::API
      version 'v1'
      format :json

      resource :tasks do
        desc "Return list of tasks"
        get do
          Task.all
        end
      end
    end
  end
end
