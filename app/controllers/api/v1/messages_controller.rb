class Api::V1::MessagesController < ApplicationController
  def create
    if params[:recipient] && params[:message]
      recipient = params[:recipient]
      message = params[:message]
      scheduled_at = params[:scheduled_at]

      # create a new message object
      new_message = Message.create(recipient: recipient, message: message, scheduled_at: scheduled_at)

      if scheduled_at.present?
        scheduled_at = DateTime.parse(scheduled_at)
        # schedule the message to be sent in the future
        SendScheduledMessageJob.set(wait_until: scheduled_at).perform_later(new_message)
      else
        # send the message immediately
        send_message(new_message)
      end

      render json: { message: "Message sent successfully" }, status: :ok
    else
      render json: { error: "Recipient and message are required" }, status: :unprocessable_entity
    end
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
  