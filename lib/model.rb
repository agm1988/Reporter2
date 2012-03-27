DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/lib/reporter.db")

class User
  require 'bcrypt'

  EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i

    include DataMapper::Resource

    property :id,              Serial
    property :name,            String
    property :email,           String, :format => EMAIL_REGEX
    property :login,           String, :required => true, :unique => true
    property :position,        String
    property :password_hash,   String
    property :password_salt,   String
    property :created_at,   DateTime
    attr_accessor :password, :password_confirmation

   has n, :records
   has n, :projects, :through => :records

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


class Project
    include DataMapper::Resource

    property :id,          Serial
    property :name,        String

    has n, :records
    has n, :users, :through => :records

end
#
class Record

    include DataMapper::Resource

    property :id,                Serial
    property :reporting_type,    String
    property :spend_time,        String
    property :date,              DateTime
    property :description,       Text
    attr_accessor :time

    belongs_to :user, :key => true
    belongs_to :project, :key => true

    before :save, :set_minutes

    validates_presence_of :description
    validates_length_of :description, :max => 255
    validates_format_of :time, :with => /^[0-9]{1}:[0-5]{1}[0-9]{1}$/
    validates_presence_of :time

    def set_minutes
      self.spend_time =  time.split(':').first.to_i * 60 + time.split(':').last.to_i
    end

  def self.selfd
    all(:reporting_type => "self_deployment")
  end

  def self.work
    all(:reporting_type => "working")
  end

  def self.extra
    all(:reporting_type => "extra")
  end

  def self.team
    all(:reporting_type => "team")
  end

  def self.this_month(month)
    date_a = DateTime.new Date.today.year, month, 1
    date_b = (date_a >> 1) + 1
    all(:date => date_a..date_b)
  end

  def self.this_day2(day)
    date_c = DateTime.new Date.today.year, month, day.to_i
    all(:date => date_c)
  end

  def self.this_day(month, day)
    date = DateTime.new Date.today.year, month, day.to_i
    all(:date => date)

  end




end

  DataMapper.auto_upgrade!