# SES API for Rails  
Basic SES API integration with Rails specifically for transaction based emails - contact emails, user emails, etc.  

## Install the SES API Rails gem  
```
# Gemfile
gem 'ses_api-rails', git: 'https://github.com/cickes/ses_api-rails.git'
```  
`bundle install`  

## High Level Integration Details  
1. Set environment variables for your AWS credentials  
    ```
    ENV['SES_SECRET_ACCESS_KEY']
    ENV['SES_AWS_ACCESS_KEY_ID']
    ENV['AWS_REGION']
    ENV['SES_ENDPOINT']
    ```
  There are many ways to accomplish this but I recommend the [Figaro Gem](https://github.com/laserlemon/figaro).  

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
1. After the ses_api-rails gem is installed, add your Amazon AWS / SES credentials to environment variables.  
    NOTE:  There are many ways to set environment variables.  This example uses the Figaro gem.  
    ```
    # Gemfile  
    gem 'figaro'  
    ```  
    `bundle install`  
    `rails g figaro:install`  
    ```
    # config/application.yml  
    ```
    SES_SECRET_ACCESS_KEY: "secret_access_key"  
    SES_AWS_ACCESS_KEY_ID: "aws_access_key_id"  
    AWS_REGION:  "us-east-1"  
    SES_ENDPOINT:  "email.us-east-1.amazonaws.com"
    ```
2.  Create a Mailer that subclasses the SesApi::Rails::Mailer  
    `rails g mailer ContactMailer`  
    If you are only sending email from the Amazon Ses Api, you can subclass the ApplicationMailer.  Otherwise subclass the Mailer that will use the Ses delivery method.  
    * Using the Amazon Ses API as the only delivery method application-wide
        ```
        # app/mailers/application_mailer.rb  
        class ApplicationMailer < SesApi::Rails::Mailer
          default from: "from@example.com"  
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
3. Instantiate the mailer where appropriate.  
    NOTE:  This assumes that you have a form, model, etc. & is not covered in the installation guide of this gem.   
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

## Troubleshooting
Is the library included?  One way to do so is to autoload all library sub-directories:  
`config.autoload_paths += Dir["#{config.root}/lib/**/"]`  
  

