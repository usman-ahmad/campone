module API
  module V1
    class Root < Grape::API
      mount API::V1::Projects
      mount API::V1::Tasks
      mount API::V1::Apisessions
    end
  end
end
