require 'sinatra/base'
require "data_mapper"

class LoginScreen < Sinatra::Base
  before do
    @flash = session[:flash] || {}
    session[:flash] = nil
  end

      module ReportHelper
      def title(value = nil)
        @title = value if value
        @title ? "Controller Demo - #{@title}" : "Controller Demo"
      end

      #flash helpers

      def flash(args={})
        session[:flash] = args
      end

      def flash_now(args={})
        @flash = args
      end
    end
    helpers ReportHelper
  enable :sessions

  get('/login') { erb :login }

  post('/login') do
   #params[:user][:login] == "admin" && params[:user][:password] == "admin"


    #  session[:user_id] = params[:user][:login]
    #  redirect '/'
    #else
    #  redirect '/login'
    #end

    #(params[:user][:login] == "newcomer" && params[:user][:password]) == "secret"
    user = User.authenticate(params[:user][:login], params[:user][:password])
    if user
      session[:user_id] = user.id
      if user.login == "newcomer"
         redirect '/new'
      else
        redirect '/'
      end

    else
      flash(:notice => "Wrong login/password combination")
      redirect '/login'
    end

  #end
  #session[:user_id] = true
  #redirect '/new'

  end
end

class Reporter < Sinatra::Base


  #helpers ApplicationHelper
  # "прослойка" будет запущена перед фильтрами

#configure(:development) { set :session_secret, "something" }
  use LoginScreen

  before do
    unless session[:user_id]
      @flash = session[:flash] || {}
      session[:flash] = nil
      halt "Access denied, please <a href='/login'>login</a>."
    end
  end

  get('/') do


  erb "Hello #{session[:user_id]} !!!."
  end

  get '/new' do
    #session[:user_id] = nil
    title "Create new account"
    erb :new_user
  end

  post '/create' do
   @user = User.new(params[:user])
   if @user.save
     session[:user_id] = nil
     redirect  "/"
   else
     redirect('/new')
   end
  end


end