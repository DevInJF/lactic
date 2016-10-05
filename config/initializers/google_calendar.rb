require 'google_calendar'
::GOOGLE_CALENDAR_CLIENT = Google::Calendar.new(:client_id     => '640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
                           :client_secret => 'BLTVmLyIF1X6pRFdEMl9Ox9v',
                           :calendar      => 'lacticinc@gmail.com',
                           # :redirect_url  => "urn:ietf:wg:oauth:2.0:oob" # this is what Google uses for 'applications'
                           :redirect_url  => 'https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect'
)

# redirect_to client.authorization_uri.to_s