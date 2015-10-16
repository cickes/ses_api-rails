require 'ses_api/rails/api'
module SesApi
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
#        ActiveSupport.on_load(:action_mailer) do
          ActionMailer::Base.add_delivery_method :ses, SesApi::Rails::Api, {}
#        end
#        ActionMailer::Base.add_delivery_method :ses, SesApi::Rails::Api, {}
      end

    end
  end
end
