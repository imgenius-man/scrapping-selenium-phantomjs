class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,:rememberable, :validatable, :registerable, :trackable#, :recoverable

  # Setup accessible (or protected) attributes for your model
  # attr_accessor :email, :password, :password_confirmation, :remember_me
  # attr_accessor :title, :body
end
