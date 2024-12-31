module Helpers
  def css(csss, constants)
    puts 'csssssssssssssss'
    static_url = constants[:static_url]
    resp = ''
    if defined? csss
      csss.each do |file|
        temp = '<link href="' + static_url + file + '.css" rel="stylesheet"/>'
        resp = resp + temp
      end
    end
    resp
  end

  def js(jss = nil, constants)
    puts 'jssssssssssssss'
    static_url = constants[:static_url]
    resp = ''
    if jss != nil
      if defined? jss
        jss.each do |file|
          temp = '<script src="' + static_url + file + '.js" type="text/javascript"></script>'
          resp = resp + temp
        end
      end
    end
    resp
  end

  def check_session_true
    if session[:logged].nil? || !session[:logged]
      redirect '/login'
    end
  end

  def if_session_true_go_home
    if session[:logged]
      redirect '/'
    end
  end
end