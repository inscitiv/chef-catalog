def conjur_attributes
  { 
    :domain => "localdomain",
    :inscitiv => {
      :project => "test",
      :owner => "kgilpin",
      :server_hostname => "localhost.localdomain",
      :ldap => {
        :root_bind_password => "secret"
      },
      :aws_users => {
        :server_events => {
          :queue_url => "https://sqs.us-east-1.amazonaws.com/234457590086/ServerEvents",
          :access_key_id => "<server_events_access_key_id>",
          :secret_access_key => "<server_events_secret_access_key>"
        }
      }
    }
  }
end