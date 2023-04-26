class SendScheduledMessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    send_message(message)
    message.destroy # destroy the message after it has been sent
  end

  private

  def send_message(message)
    # send the message via SMS or email based on the recipient format
    if message.recipient.include?('@')
      send_email(message)
    else
      send_sms(message)
    end
  end

  def send_sms(message)
    # initialize the Twilio client
    client = Twilio::REST::Client.new Rails.application.credentials.twilio[:account_sid], Rails.application.credentials.twilio[:auth_token]

    # send the SMS message
    client.messages.create(
      from: Rails.application.credentials.twilio[:phone_number],
      to: message.recipient,
      body: message.message
    )
  end

  def send_email(message)
    # initialize the Mail client
    Mail.defaults do
      delivery_method :smtp, {
        address: Rails.application.credentials.mailgun[:smtp_server],
        port: Rails.application.credentials.mailgun[:smtp_port],
        user_name: Rails.application.credentials.mailgun[:smtp_login],
        password: Rails.application.credentials.mailgun[:smtp_password]
      }
    end

    # send the email message
    Mail.deliver do
      from Rails.application.credentials.mailgun[:smtp_login]
      to message.recipient
      subject 'Congratulations'
      body message.message
    end
  end
end
