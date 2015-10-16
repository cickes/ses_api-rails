require 'ses_api/rails/version'
require 'ses_api/rails/railtie'

module SesApi
  module Rails

    class Mailer < ActionMailer::Base
      self.delivery_method = :ses
    end

    class SesError < StandardError; end

  end
end
