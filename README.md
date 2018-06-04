# ResumableJob

[![Build Status: master](https://travis-ci.com/SleeplessByte/resumable_job.svg?token=FpDLv4Yva15pzqYpq9Hk&branch=master)](https://travis-ci.com/SleeplessByte/resumable_job) 
[![Gem Version](https://badge.fury.io/rb/resumable_job.svg)](https://badge.fury.io/rb/resumable_job)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

Make any `ActiveJob` resumable.

Use exception flow to make jobs exceptionally resumable, whilst retaining other state, with automatic exponential
backoff handling. ActiveJob is not a dependency, so this could be used with "anything". Adds a `module` to `include`
somewhere that adds a method which yields a block. During this block, you can throw a `ResumableJob::ResumeLater` to 
call the following:

```Ruby
self.class
    .set(wait_until: resume_at || ResumableJob::Backoff.to_time(attempt))
    .perform_later(pause(state).merge(attempt: attempt + 1))
````

State is passed through `pause` and when `pause` is not overridden will be all the arguments you passed to your job plus
an `attempt` argument that is steadily increased in order to to exponential backoff.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resumable_job'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install resumable_job

## Usage

### Make a job resumable

Simple example to implement pagination that resumes later if you receive a "Rate Limit Exceeded".

```Ruby
class FetchDataJob < ApplicationJob
  include ResumableJob::Resumable
  
  def perform(state)
    page = state.fetch(:page) { 1 }
    
    resumable(state) do
      loop do
        result = DataFetcher.call(page: page)
        raise ResumableJob::ResumeLater(state: state.merge(page: page)) if result.status == 429
        break unless result.next_page?
          
        page = result.next_page
      end
    end
  end
end
```

### Turn inner exception into resumable

When the exception has more information (for example a "rate limit reset" value), it can be turned into a resume later.
Additionally, the `state` of the resume later exception will me merged into the original state, and then into the pause
state.
 

```Ruby
class FetchDataJob < ApplicationJob
  include ResumableJob::Resumable

  def perform(state)
    resumable(state) do
      fetch_data(state)
    end
  end

  private

  def fetch_data(state)
    RateLimitableFetcher.call(state)
  rescue RateLimitableFetcher::RateLimited => ex
    raise ResumableJob::ResumeLater.new(state: state, utc: ex.retry_at, message: ex.message)
  end
end
```

### Filter out keys from the state
Some state is not serializable. You may be calling your job with `perform_now`, but when it resumes later, some
arguments can not be serialized. Use the `pause` override to include state not originally present, modify state that is
not passed by your exception (ResumeLater exception state), or remove state. 

```Ruby
class FetchDataJob < ApplicationJob
  include ResumableJob::Resumable
  
  def pause(state)
    state.slice(:attempt, :page, :token)
  end
end
```
  
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SleeplessByte/resumable_job.
