module API
  class Root < Grape::API
    prefix    'api'
    format    :json

    # rescue_from :all, :backtrace => true
    # error_formatter :json, API::ErrorFormatter

    helpers do
      def warden
        env['warden']
      end

      def authenticated
        return true if warden.authenticated?
        params[:access_token] && @user = User.find_by_authentication_token(params[:access_token])
      end

      def current_user
         warden.user || @user
      end
    end

    mount API::V1::Root
    mount API::Apisessions
    # mount API::V2::Root
  end
end
