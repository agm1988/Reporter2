module ReportHelper
  def title(value = nil)
    @title = value if value
    @title ? "Controller Demo - #{@title}" : "Controller Demo"
  end

  def flash(args={})
    session[:flash] = args
  end

  def flashsesion(args={})
    session[:flash2] = args
  end

  def flash_now(args={})
    @flash = args
  end

  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end

  def time_sum(arr)
    tmp = arr.collect(&:spend_time).collect(&:to_i).inject(0, &:+)
    "#{tmp / 60}h : #{tmp % 60 }min"
  end

  def hours(time)
    "#{time.to_i / 60}h : #{time.to_i % 60 }min"
  end

  def show_date(day, month)
      "__#{show_month(month)} #{day} ___"
  end

  def show_month(month)
    case month
      when 1
        "January"
      when 2
        "february"
      when 3
        "March"
      when 4
        "April"
      when 5
        "May"
      when 6
        "June"
      when 7
        "July"
      when 8
        "August"
      when 9
        "September"
      when 10
        "October"
      when 11
        "November"
      when 12
        "December"
      else
        "Wrong month number"
    end

  end
end