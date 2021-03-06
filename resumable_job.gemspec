
lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resumable_job/version'

Gem::Specification.new do |spec|
  spec.name          = 'resumable_job'
  spec.version       = ResumableJob::VERSION
  spec.authors       = ['Derk-Jan Karrenbeld']
  spec.email         = ['derk-jan+github@karrenbeld.info']

  spec.summary       = 'Make an ActiveJob resumable'
  spec.license       = 'MIT'

  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/SleeplessByte/resumable_job/issues',
    'changelog_uri'     => 'https://github.com/SleeplessByte/resumable_job/CHANGELOG.md',
    'homepage_uri'      => 'https://github.com/SleeplessByte/resumable_job',
    'source_code_uri'   => 'https://github.com/SleeplessByte/resumable_job'
  }

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = 'https://gems.sleeplessbyte.technology'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.platform = 'java' if RUBY_PLATFORM =~ /java/

  spec.add_development_dependency 'bundler', '~> 2'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
end
