DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/lib/reporter.db")

class User
    include DataMapper::Resource

    property :id,           Serial
    property :name,        String
    property :email,        String
    property :login,        String
    property :position,        String
    property :password,        String
    property :created_at,   DateTime

  def self.authenticate(login, password)
    user = User.first(:login => login)
    if user && user.password == password
      user
    else
      nil
    end

  end

end

  DataMapper.auto_upgrade!