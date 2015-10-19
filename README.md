# SES API for Rails  
Basic SES API integration with Rails specifically for transaction based emails - contact emails, user emails, etc.  

## Install the SES API Rails gem  
```
# Gemfile
gem 'ses_api-rails', git: 'https://github.com/cickes/ses_api-rails.git'
```  
`bundle install`  

## High Level Integration Details  
1. Create an initializer file defining your AWS credentials as constants  
    ```
    # config/initializers/ses_api-rails.rb
    SesApi::Rails.configure do |config|
      config.secret_access_key = ENV['SECRET_ACCESS_KEY']
      config.access_key_id = Figaro.env.access_key_id
      config.aws_region = "us-east-1"
      config.ses_endpoint = "email.us-east-1.amazonaws.com"
    end
    ```
  There are many ways to accomplish this.  The above shows 3 different methods.  Personally I recommend the [Figaro Gem](https://github.com/laserlemon/figaro).  

2. Subclass the SesApi::Rails::Mailer class in your CustomMailer or in your ApplicationMailer  
    ```
    # app/mailers/custom_mailer.rb
    class CustomMailer < SesApi::Rails::Mailer
      ...
      def contact
        mail to: "you@example.com", subject: "Via Ses"
      end
    end
    ```  

3. Instantiate the mailer where appropriate.  
    ```
    # app/controllers/contacts_controller.rb  
    def create
      @contact = Contact.new(contact_params)
      if @contact.valid?
        CustomMailer.contact(@contact).deliver_now!
        redirect_to contact_success_path, notice: "Thank you for your contact request."
      else
        render :new
      end
    end
    ```

## A Step By Step Example  
1. (OPTIONAL) After the ses_api-rails gem is installed, add your Amazon AWS / SES credentials to environment variables.  
    NOTE:  There are many ways to set environment variables.  This example uses the Figaro gem.
    ```
    # Gemfile  
    gem 'figaro'  
    ```  
    `bundle install`  
    `figaro install`  
    ```
    # config/application.yml  
    ```
    SECRET_ACCESS_KEY: "secret_access_key"  
    AWS_ACCESS_KEY_ID: "aws_access_key_id"  
    AWS_REGION:  "us-east-1"  
    SES_ENDPOINT:  "email.us-east-1.amazonaws.com"
    ```
2.  Create an initializer that assigns your AWS credentials to constants.  There are multiple ways to accomplish this including simply hardcoding a string value.  The example below uses Figaro environment variables.  
    ```
    # config/initializers/ses_api-rails.rb
    SesApi::Rails.configure do |config|
      config.secret_access_key = Figaro.env.secret_access_key
      config.access_key_id = Figaro.env.access_key_id
      config.aws_region = Figaro.env.aws_region
      config.ses_endpoint = Figaro.env.ses_endpoint
    end
    ```
3.  Create a Mailer that subclasses the SesApi::Rails::Mailer  
    `rails g mailer ContactMailer`  
    If you are only sending email from the Amazon Ses Api, you can subclass the ApplicationMailer.  Otherwise subclass the Mailer that will use the Ses delivery method.  
    * Using the Amazon Ses API as the only delivery method application-wide
        ```
        # app/mailers/application_mailer.rb  
        class ApplicationMailer < SesApi::Rails::Mailer
          default from: "from@example.com"  
          layout 'mailer'
        end
        ```
        ```
        # app/mailers/contact_mailer.rb  
        class ContactMailer < ApplicationMailer
          ...
          def contact
            mail to: "you@example.com", subject: "Via Ses"
          end
        end
        ```
    Create a mailer view(s)  
    ```
    # app/views/contact_mailer/contact.html.erb  
    <h1>Hello new contact</h1>
    <p>Include instance variables as you like using @contact.attribute</p>
    ```
    ```
    # app/views/contact_mailer/contact.text.erb  
    This is a text version  
    Hello new contact
    ````
4. Instantiate the mailer where appropriate.  
    NOTE:  This assumes that you have a form, model, etc. & is not covered in the installation guide of this gem.   
    ```
    # app/controllers/contacts_controller.rb  
    ...
    def create
      @contact = Contact.new(contact_params)
      if @contact.valid?
        ContactMailer.contact(@contact).deliver_now!
        redirect_to contact_success_path, notice: "Thank you for your contact request."
      else
        render :new
      end
    end
    ...
    ```

## Troubleshooting
Is the library included?  One way to do so is to autoload all library sub-directories:  
`config.autoload_paths += Dir["#{config.root}/lib/**/"]`  
  

