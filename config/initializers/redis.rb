require 'redis'

REDIS = Redis.new(host: 'localhost', port: 6379)

REDIS.del("ranking")