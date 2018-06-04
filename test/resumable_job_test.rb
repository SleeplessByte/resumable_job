require 'test_helper'

class ResumableJobTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::ResumableJob::VERSION
  end
end
