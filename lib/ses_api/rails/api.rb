module SesApi
  module Rails

    # defines Mail::delivery_method
    class Api < Mail::SMTP
      ALGO = "AWS4-HMAC-SHA256"
      SECRET_ACCESS_KEY = ENV['SES_SECRET_ACCESS_KEY']
      ACCESS_KEY_ID = ENV['SES_AWS_ACCESS_KEY_ID']
      AWS_REGION = ENV['AWS_REGION']
      SERVICE = "ses"
      TERM_STR = "aws4_request"

      class_attribute :conn, :mail

      self.conn = Faraday.new(:url => "https://#{ENV['SES_ENDPOINT']}") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      def initialize(values)
        self.settings = {
          }.merge!(values)
      end

      def settings
        {}
      end

      def deliver!(mail)
        self.mail = mail
        dt = create_datetime
        credential_scope = create_credential_scope(dt)

        response = conn.post do |req|
          req.body = create_payload
          hashed_payload = Digest::SHA256.hexdigest(req.body) #.downcase
          headers = { :'X-Amz-Date' => dt, Host: ENV['SES_ENDPOINT'], :'X-Amz-Content-Sha256' => hashed_payload }
          headers.each do |addtl_header, value|
            req.headers[addtl_header.to_s.camelize] = value
          end
          req.headers['Authorization'] = create_auth_header(dt, credential_scope, hashed_payload, headers)
        end
      
        raise SesApi::Rails::SesError if response.status != 200
      end

      def create_datetime
        # returns ISO8601 Basic format YYYYMMDD'T'HHMMSS'Z'
        timestamp = Time.now.getutc
        timestamp.strftime('%Y%m%dT%H%M%SZ')
      end

      def create_credential_scope(request_datetime)
        "#{request_datetime[0,8]}/#{AWS_REGION}/#{SERVICE}/#{TERM_STR}"
      end

      def create_payload
        to = mail.to.each_with_index.map { |email, i| "&Destination.ToAddresses.member.#{i+1}=#{CGI::escape(email)}"}.join
        cc = mail.cc.each_with_index.map { |email, i| "&Destination.CCAddresses.member.#{i+1}=#{CGI::escape(email)}"}.join if mail.cc.present?
        bcc = mail.bcc.each_with_index.map { |email, i| "&Destination.BCCAddresses.member.#{i+1}=#{CGI::escape(email)}"}.join if mail.bcc.present?
        from = "&Source=#{CGI::escape(mail.from[0])}"
        subject = "&Message.Subject.Data=#{CGI::escape(mail.subject)}"

        if mail.body.raw_source.present?
          body = "&Message.Body.Html.Data=#{CGI::escape(mail.body.raw_source)}&Message.Body.Html.Charset=UTF-8"
          body << "&Message.Body.Text.Data=#{CGI::escape(mail.body.raw_source)}&Message.Body.Text.Charset=UTF-8"
        else
          body = "&Message.Body.Html.Data=#{CGI::escape(mail.html_part.body.raw_source)}&Message.Body.Html.Charset=UTF-8"
          body << "&Message.Body.Text.Data=#{CGI::escape(mail.text_part.body.raw_source)}&Message.Body.Text.Charset=UTF-8"
        end

        payload = "AWSAccessKeyId=#{ACCESS_KEY_ID}&Action=SendEmail#{to}#{cc}#{bcc}#{body}#{subject}#{from}"
      end

      def create_canonical_request(headers, hashed_payload, signed_headers)
        http_request_method = "POST"
        canonical_uri = "/"
        canonical_query_str = ""
        canonical_headers = headers.sort.map { |k,v| "#{k.downcase}:#{v.strip}\n"}.join
        canonical_request = [http_request_method, canonical_uri, canonical_query_str, canonical_headers, signed_headers, hashed_payload].join("\n")
      end

     def create_auth_header(request_datetime, credential_scope, hashed_payload, headers)
        signing_key = create_signing_key(request_datetime)
        signed_headers = headers.sort.map { |k,v| "#{k.downcase}" }.join(";")
        string_to_sign = create_str_to_sign(request_datetime, credential_scope, headers, hashed_payload, signed_headers)
        signing_signature = create_signature(signing_key, string_to_sign)
        return "#{ALGO} Credential=#{ACCESS_KEY_ID}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signing_signature}"
      end

      def create_signing_key(request_datetime)
        key_date = hmac("AWS4" + SECRET_ACCESS_KEY, request_datetime[0,8])
        key_region = hmac(key_date, AWS_REGION)
        key_service = hmac(key_region, SERVICE)
        key_credentials = hmac(key_service, TERM_STR)
      end

      def create_str_to_sign(request_datetime, credential_scope, headers, hashed_payload, signed_headers)
        canonical_request = create_canonical_request(headers, hashed_payload, signed_headers)
        return "#{ALGO}\n#{request_datetime}\n#{credential_scope}\n#{Digest::SHA256.hexdigest(canonical_request)}"
      end

      def create_signature(signing_key, string_to_sign)
        hexhmac(signing_key, string_to_sign)
      end

      def hmac(key, value)
        OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), key, value)
      end

      def hexhmac(key, value)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), key, value)
      end
    end
  end
end
