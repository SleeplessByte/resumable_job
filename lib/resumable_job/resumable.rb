module ResumableJob

  ##
  # Include in an {ActiveJob::Job} to make resumable.
  #
  # Adds a yield guard resumable that catches any thrown instance of {ResumeLater}, which enqueues the job at a
  #   later time, either by getting a utc in the future from the exception or using a backoff algorithm.
  #
  module Resumable
    private

    ##
    # Resumable guard
    #
    # @param state [Hash] the job state
    #
    # @example Make a job resumable
    #
    #   class FetchDataJob < ApplicationJob
    #     include ResumableJob::Resumable
    #
    #     def perform(state)
    #       page = state.fetch(:page) { 1 }
    #
    #       resumable(state) do
    #         loop do
    #           result = DataFetcher.call(page: page)
    #           raise ResumableJob::ResumeLater(state: state.merge(page: page)) if result.status == 429
    #           break unless result.next_page?
    #
    #           page = result.next_page
    #         end
    #       end
    #     end
    #   end
    #
    # @example Filter out state
    #
    #   class FetchDataJob < ApplicationJob
    #     include ResumableJob::Resumable
    #
    #     def pause(state)
    #       state.slice(:attempt, :page, :token)
    #     end
    #
    #   end
    #
    # @example Turn inner exception into resumable
    #
    #   class FetchDataJob < ApplicationJob
    #     include ResumableJob::Resumable
    #     def perform(state)
    #       resumable(state) do
    #         fetch_data(state)
    #       end
    #     end
    #
    #     private
    #
    #     def fetch_data(state)
    #       RateLimitableFetcher.call(state)
    #     rescue RateLimitableFetcher::RateLimited => ex
    #       raise ResumableJob::ResumeLater.new(state: state, utc: ex.retry_at, message: ex.message)
    #     end
    #   end
    #
    def resumable(state)
      attempt = state.fetch(:attempt) { 0 }
      yield attempt
    rescue ResumableJob::ResumeLater => ex
      resume_later(
        resume_at: ex.utc,
        state: state.merge(ex.state),
        attempt: attempt
      )
    end

    ##
    # Schedules the current job to +resume_at+ a later time, either given or calculated from +attempt+.
    #
    # @see #pause
    # @see ResumableJob::Backoff.to_time
    #
    # @param [NilClass, Numeric] resume_at
    # @param [Numeric] attempt the current attempt
    # @param [Hash] state state to merge with the state from {#pause}
    #
    def resume_later(resume_at: nil, state: {}, attempt: 0)
      self.class
          .set(wait_until: resume_at || ResumableJob::Backoff.to_time(attempt))
          .perform_later(pause(state).merge(attempt: attempt + 1))
    end

    ##
    # Calculates the state to be passed for rescheduling this job.
    #   By default outputs input, override {#pause} to change what is passed to the job.
    #
    # @param [Hash] state
    # @return [Hash] state
    #
    # @example Remove a key from the state
    #
    #   def pause(state)
    #     state.except(:key_to_exclude)
    #   end
    #
    # @example Update the state before pausing
    #
    #   def pause(state)
    #     state.merge!(foo: state[:foo] * 2)
    #   end
    #
    def pause(state)
      state
    end
  end
end
