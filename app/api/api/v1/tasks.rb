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
        get do
           Task.all
        end
      end

    end
  end
end
