module API
  module V1
    class Root < Grape::API
      mount API::V1::Projects
      mount API::V1::Tasks
    end
  end
end
