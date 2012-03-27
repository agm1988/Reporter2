require 'sinatra/base'
require "data_mapper"

class LoginScreen < Sinatra::Base

  configure(:development) { set :session_secret, "something"
                            set :raise_errors, Proc.new { false }
                            set :show_exceptions, false}

  before do
    @flash = session[:flash2] || {}
    session[:flash2] = nil
  end

  helpers ReportHelper
  enable :sessions

  get('/login') { erb :login }

  post('/login') do
    user = User.authenticate(params[:user][:login], params[:user][:password])
    if user
      session[:user_id] = user.id
      if user.login == "newcomer"
         redirect '/new'
      else
        redirect '/'
      end
    else
      flashsesion(:notice => "Wrong login/password combination")
      redirect '/login'
    end
  end

  get '/logout' do
    session[:user_id] = nil
    redirect "/"
  end

end

class Reporter < Sinatra::Base
  use LoginScreen

  before do
    @flash = session[:flash] || {}
    session[:flash] = nil
    unless session[:user_id]
      redirect '/login'
    end
  end

  helpers ReportHelper

 get('/') do
    erb :calendar
 end

  get '/new' do
    title "Create new account"
    erb :new_user
  end

  post '/create' do
   @user = User.new(params[:user])
   if @user.save
     session[:user_id] = nil
     flash(:notice => "Accoutn successfuly created!")
     redirect  "/"
   else
     erb :new_user
   end
  end

  get '/calendar_show' do
    @date = DateTime.parse(params[:report][:date]) if !session[:date]
    @date = DateTime.parse(session[:date]) if session[:date]
    session[:date] = nil
    @records = Record.all(:date => @date)     #--------------
    @selfd = @records.selfd
    @work = @records.work
    @extra = @records.extra
    @team = @records.team
    erb :calendar_show
  end

  post '/new_record' do
    @projects = Project.all
    @date = DateTime.parse(params[:date])
    @records = Record.all(:date => @date)
    erb :new_record
  end

  post '/create_record' do
   @date = DateTime.parse(params[:record][:date])
   @record = Record.new(params[:record])
   if @record.save
     flash(:notice => "Report successfully created!")
     session[:date] = params[:record][:date]
     redirect  "/calendar_show"

   else
     @projects = Project.all
     flash(:notice => "Record was not created!")
     @records = Record.all(:date => @date)
     erb :new_record
   end
  end

  post '/consolidated' do
    @month = params[:month].to_i
    @records = current_user.records.this_month(params[:month].to_i)
    @days = @records.collect(&:date).collect(&:day).uniq
    @projects = current_user.projects.uniq
    erb :consolidated
  end

  not_found do
    title 'Not Found!'
    erb :not_found
  end

  error do
    @message = "error: #{request.env['sinatra.error'].to_s}"
    erb :error
  end



end