class Notifier < ActionMailer::Base
  default :from => "\"XEMS\" <rails.it18@gmail.com>"
  def send_email(info)
    mail :to => "\"#{info[:name]}\" <#{info[:email]}>", :subject => info[:subject], :body => info[:message]
  end
end