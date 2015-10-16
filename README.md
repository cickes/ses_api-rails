# Rails SES API  
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
    CustomMailer.contact(@contact).deliver_now
    redirect_to contact_success_path, notice: "Thank you for your contact request."
  else
    render :new
  end
end
```
## A Step By Step Example  



# Troubleshooting
Is the library included?  One way to do so is to autoload all library sub-directories:  
`config.autoload_paths += Dir["#{config.root}/lib/**/"]`  
  

