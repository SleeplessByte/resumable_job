module ResumableJob
  class ResumeLater < RuntimeError
    def initialize(state: {}, utc: nil, message:)
      self.state = state || {}
      self.utc = utc

      super message
    end

    attr_accessor :state, :utc
  end
end
