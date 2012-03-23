DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/lib/reporter.db")

class User
  require 'bcrypt'

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

    include DataMapper::Resource

    property :id,           Serial
    property :name,        String
    property :email,        String, :format => EMAIL_REGEX
    property :login,        String, :required => true, :unique => true
    property :position,        String
    property :password_hash,        String
    property :password_salt,        String
    property :created_at,   DateTime
    attr_accessor :password, :password_confirmation

   validates_presence_of :name, :email, :position
   validates_presence_of :password
   validates_confirmation_of :password
   validates_length_of :name, :login, :password, :min => 6


    before :save, :encrypt_password

  def encrypt_password
    if password
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end

  def self.authenticate(login, password)
    user = User.first(:login => login)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end

  end

end


#class Project
#    include DataMapper::Resource
#
#    property :id,           Serial
#    property :name,        String
#
#
#
#end

  DataMapper.auto_upgrade!