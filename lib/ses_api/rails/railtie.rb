require 'ses_api/rails/api'
module SesApi
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        ActionMailer::Base.add_delivery_method :ses, SesApi::Rails::Api, {}
      end
    end
  end
end
