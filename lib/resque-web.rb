require 'resque_scheduler'
require 'resque_scheduler/server'

Resque.schedule = YAML.load_file('config/resque_schedule.yml')