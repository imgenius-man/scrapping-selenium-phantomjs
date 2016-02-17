class UserMailer < ActionMailer::Base

   def registration_confirmation(user,book)
   	 @user = user
   	 @book = book
     mail(:to => user.email, :subject => "Registered", :from => "eifion@asciicasts.com")
   end

end
