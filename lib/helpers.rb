module ReportHelper
  def title(value = nil)
    @title = value if value
    @title ? "Controller Demo - #{@title}" : "Controller Demo"
  end

      #flash helpers

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
end