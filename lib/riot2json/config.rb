module Riot2JSON
  class Config
    RTMP_HOST = "prod.na1.lol.riotgames.com"
    RTMP_PORT = 2099
    TC_URL = "rtmps://#{RTMP_HOST}:#{RTMP_PORT}/"
    QUEUE_SERVER ="lq.%s.lol.riotgames.com"
    QUEUE_PATH ="/login-queue/rest/queue/authenticate"
  end
end

