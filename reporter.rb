require 'sinatra/base'
require "data_mapper"

class LoginScreen < Sinatra::Base

  configure(:development) { set :session_secret, "something" }

  before do
    @flash = session[:flash2] || {}
    session[:flash2] = nil
  end

  #module ReportHelper
  #  def title(value = nil)
  #    @title = value if value
  #    @title ? "Controller Demo - #{@title}" : "Controller Demo"
  #  end
  #
  #    #flash helpers
  #
  #  def flashsesion(args={})
  #    session[:flash2] = args
  #  end
  #
  #  def flash_now(args={})
  #    @flash = args
  #  end
  #
  #  def current_user
  #    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  #  end
  #end




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
      # redirect '/'
      if user.login == "newcomer"
         redirect '/new'
      else
        redirect '/'
      end

    else
      flashsesion(:notice => "Wrong login/password combination")
      redirect '/login'
    end

  #end
  #session[:user_id] = true
  #redirect '/new'

  end

  get '/logout' do
    session[:user_id] = nil
    redirect "/"
  end

end

class Reporter < Sinatra::Base


  #helpers ApplicationHelper
  # "прослойка" будет запущена перед фильтрами

#configure(:development) { set :session_secret, "something" }
  use LoginScreen

  before do
      @flash = session[:flash] || {}
      session[:flash] = nil
    unless session[:user_id]
      redirect '/login'
      #halt "Access denied, please <a href='/login'>login</a>."
    end
  end

    #module ReportHelper
    #  def title(value = nil)
    #    @title = value if value
    #    @title ? "Controller Demo - #{@title}" : "Controller Demo"
    #  end
    #
    #  #flash helpers
    #
    #  def flash(args={})
    #    session[:flash] = args
    #  end
    #
    #  def flash_now(args={})
    #    @flash = args
    #  end
    #
    #  def current_user
    #    @current_user ||= User.get(session[:user_id]) if session[:user_id]
    #  end
    #
    #  def time_sum(arr)
    #     tmp = arr.collect(&:spend_time).collect(&:to_i).inject(0, &:+)
    #    "#{tmp / 60}h : #{tmp % 60 }min"
    #  end
    #end
    helpers ReportHelper


  # this will only affect Sinatra::Application

 get('/') do
    erb :calendar
  # erb "Hello #{session[:user_id]} !!!."
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
     flash(:notice => "Accoutn successfuly created!")
     redirect  "/"
   else
     erb :new_user
   end
  end

  get '/calendar_show' do
    #@selfd = Record.selfd

    #@date = params[:report][:date] if !session[:date]    # ------------------------
    #@date = session[:date] if session[:date]             # --------------------------

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
    # @date = DateTime.parse(params[:report][:date])
    #@date = params[:date] # ---------------------------------------------------------------
    @date = DateTime.parse(params[:date])
    @records = Record.all(:date => @date)
    erb :new_record
  end

  post '/create_record' do
    #@user = User.get(current_user.id)
    #if @user.records.create(params[:record])
    #  flash(:notice => "Report created successfully!")
    #  redirect "/"
    #else
    #  @projects = Project.all
    #  @date = DateTime.parse(params[:report][:date])
    #  erb :new_record
    #end

   #@record = Record.new(params[:record])
    #reco
   #@date = params[:record][:date]  # --------------------------------------
   @date = DateTime.parse(params[:record][:date])
   @record = Record.new(params[:record])
   if @record.save
     flash(:notice => "Report successfully created!")
     session[:date] = params[:record][:date]
     redirect  "/calendar_show"

   else
     @projects = Project.all
     # @date = DateTime.parse(params[:report][:date])
     flash(:notice => "Record was not created!")
     @records = Record.all(:date => @date)
     erb :new_record
   end
  end

  post '/consolidated' do
    @month = params[:month].to_i
    # @reports = current_user.records.this_month(@month)

    #@projects = Project.records.this_month
    #@projects = current_user.projects.this_month
    # @pr = Project.get(1)
    # @prj = current_user.projects.get(@i).records
    # @proj = @pr.users.get(current_user.id).records
    #@rec = Project(@i).records

    #-----------------------------------
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