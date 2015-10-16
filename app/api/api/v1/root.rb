module API
  module V1
    class Root < Grape::API


      before do
        error!("401 Unauthorized", 401) unless authenticated
      end

      mount API::V1::Projects
      mount API::V1::Tasks
      mount API::V1::Projectgroup
      mount API::V1::Comments
      mount API::V1::Discussions
    end
  end
end
