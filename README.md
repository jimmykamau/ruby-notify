# Ruby on Rails API Application

This is a simple Ruby on Rails API application that sends a mock SMS or email immediately or is scheduled. It sends the words “Congratulations, your transaction is successful.”

## Prerequisites

Before you can run this application, you must have the following software installed on your system:

- Ruby 3.2.2 or higher
- Rails 7.0.4 or higher
- SQLite
- Redis

## Getting Started

To get started with this application, follow these steps:

1. Clone the repository to your local machine using the following command:

   ```
   git clone https://github.com/jimmykamau/ruby-notify.git
   ```

2. Change to the application directory:

   ```
   cd ruby-notify
   ```

3. Install the required gems:

   ```
   bundle install
   ```

4. Create the database:

   ```
   rails db:create
   ```

5. Run the database migrations:

   ```
   rails db:migrate
   ```

6. Set up your Twilio and Mailgun credentials by creating a new file `config/credentials.yml.enc`:

   ```
   EDITOR="code --wait" rails credentials:edit
   ```

   This will open a new file in your default editor. Add the following lines to this file, replacing the placeholders with your actual credentials:

   ```
   twilio:
     account_sid: YOUR_TWILIO_ACCOUNT_SID
     auth_token: YOUR_TWILIO_AUTH_TOKEN
     phone_number: YOUR_TWILIO_PHONE_NUMBER

   mailgun:
     smtp_server: YOUR_MAILGUN_SMTP_SERVER
     smtp_port: YOUR_MAILGUN_SMTP_PORT
     smtp_login: YOUR_MAILGUN_SMTP_LOGIN
     smtp_password: YOUR_MAILGUN_SMTP_PASSWORD
   ```

   Save and close the file when you're done.

7. Start the Rails server:

   ```
   rails server
   ```

   You should now be able to access the application at http://localhost:3000/.

## Usage

To use this application, you can make HTTP requests to the following endpoints:

- `POST /api/v1/messages`: Creates a new message. The request body should be a JSON object with the following keys:

  - `recipient`: The recipient of the message (phone number or email address).
  - `message`: The message to send.

  Example request:

  ```
  POST /api/v1/messages
  Content-Type: application/json

  {
    "recipient": "jane@example.com",
    "message": "Congratulations, your transaction is successful."
  }
  ```

To send a scheduled message, you can make a `POST` request to the `/api/v1/scheduled_messages` endpoint with a JSON object that includes the following keys:

- `recipient`: The recipient of the message (phone number or email address).
- `message`: The message to send.
- `scheduled_at`: The date and time when the message should be sent, in ISO 8601 format (e.g. `2023-05-01T10:00:00-05:00`).

Example request:

```
POST /api/v1/scheduled_messages
Content-Type: application/json

{
  "recipient": "jane@example.com",
  "message": "Congratulations, your transaction is successful.",
  "scheduled_at": "2023-05-01T10:00:00-05:00"
}
```

This will create a new `ScheduledMessage` record in the database, which will be processed by a background job at the specified time. When the job is processed, the message will be sent to the recipient using either Twilio or Mailgun, depending on the recipient type (phone number or email address).

You can use a tool like Postman to make HTTP requests to these endpoints and test the functionality of the application. You can find the collection [here](ruby-notify.postman_collection.json).