class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  def password_generate l
    symbols = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789"
    numbers = Time.now.to_i.to_s
    code = ""
    l.times do |i|
      r = rand(symbols.length-10)
      a = numbers[numbers.length-i].to_i
      code << symbols[a+r]
    end
    code
  end
end
