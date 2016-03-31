class PatientMailer < ActionMailer::Base

   def registration_confirmation(user,book)
   	 @user = user
   	 @book = book
     mail(:to => user.email, :subject => "Registered", :from => "eifion@asciicasts.com")
   end

   def exception_email(body)
     mail(:to => 'rehan@statpaymd.com', :subject => 'Exception',:from => "eifion@asciicasts.com", :body => body)
   end

   def HTML_validation_notification(body)
     mail(:to => 'rehan@statpaymd.com', :subject => 'HTML Validation',:from => "eifion@asciicasts.com", :body => body)
   end

end
