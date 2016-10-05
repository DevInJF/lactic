require 'resque/tasks'
# You can see the new tasks added by resque by doing:
# bundle exec rake -T resque
# rake resque:failures:sort  # Sort the 'failed' queue for the redis_multi_queue failure backend
# rake resque:work           # Start a Resque worker
# rake resque:workers        # Start multiple Resque workers
task 'resque:setup' => :environment