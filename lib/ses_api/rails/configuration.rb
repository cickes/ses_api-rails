module SesApi
  module Rails
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield configuration
    end

    class Configuration
      attr_accessor :aws_region
      attr_accessor :ses_endpoint
      attr_accessor :access_key_id
      attr_accessor :secret_access_key

      def initialize
        @aws_region = "us-east-1"
        @ses_endpoint = "email.us-east-1.amazonaws.com"
        @access_key_id = nil
        @secret_access_key = nil
      end
    end
  end
end
