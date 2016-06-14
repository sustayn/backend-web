class HomeMailer < ApplicationMailer
  def contact(name, subject, email, message)
    @name = name
    @message = message

    mail(to: 'contact@corvae.com', from: email, subject: subject)
  end
end
