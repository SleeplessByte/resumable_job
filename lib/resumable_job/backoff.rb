module ResumableJob
  class Backoff
    DEFAULT_BASE_IN_MINUTES = 1
    SECONDS_PER_MINUTE = 60

    class << self
      def to_i(*args)
        new(*args).to_i
      end

      def to_time(*args)
        new(*args).to_time
      end
    end

    delegate :to_i, to: :to_time

    def initialize(attempt, base: DEFAULT_BASE_IN_MINUTES)
      self.attempt = attempt
      self.base = base
    end

    def to_time
      Time.now + delay
    end

    private

    attr_accessor :attempt, :base

    def delay
      (2**attempt) * base * SECONDS_PER_MINUTE
    end
  end
end
