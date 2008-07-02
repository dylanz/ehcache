module Ehcache
  module Status
    UNINITIALISED = Ehcache::Java::Status::STATUS_UNINITIALISED
    ALIVE         = Ehcache::Java::Status::STATUS_ALIVE
    SHUTDOWN      = Ehcache::Java::Status::STATUS_SHUTDOWN

    STATUSES = [UNINITIALISED, ALIVE, SHUTDOWN]
  end
end
