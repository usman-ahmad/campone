module API
  module V1
    class Apisessions < Grape::API
      version 'v1'
      format :json

      resource :login do
        desc "Sign in"
        post do
           user = User.find_by_email(params["email"])
          is_present = user.valid_password?(params['password'])
          if is_present == false
            error!("Login Fail")
            else
              user.authentication_token
          end
        end
      end

      resource :logout do
        desc "Sign out"
        post do
          user = User.where(:email => params["email"], :authentication_token => params[:access_token]).first
          if user.present?
             user.update authentication_token: nil
            "logout"
          else
            error!("Could not logout")
          end
        end
      end

    end
  end
end
