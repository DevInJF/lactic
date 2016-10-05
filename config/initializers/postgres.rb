# require 'pg'
#
#
#
# USER_CONN_OPTS = {
#     :host     => 'ec2-54-204-5-56.compute-1.amazonaws.com',
#     :dbname   => 'dc1n17jp99b98k',
#     :user     => 'rbtjvkaupizvzw',
#     :password => 'D9RGQ9_SX4AEABs6Ubki8BPrxm',
#     # uncommnet on producation
#     # :sslmode => 'disable'
# }
#
#
#
# ::USERS_POSTGRES_CONNECTION = PG::Connection.open(USER_CONN_OPTS)
# Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }
# # ::USERS_POSTGRES_CONNECTION = PG::Connection.open(:dbname => 'dc1n17jp99b98k')
# # ::LACTIC_SESSIONS_POSTGRES_CONNECTION = PG::Connection.open(:dbname => 'dc1n17jp99b98k')