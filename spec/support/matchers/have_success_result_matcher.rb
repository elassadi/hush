# Matcher that may be used for testing service objects on responding
# with success result that contains payload that matches
# the one from expectation
RSpec::Matchers.define :have_success_result do |expected|
  match do |actual|
    return false unless be_success.matches?(actual)

    match(expected).matches?(actual.payload)
  end

  failure_message do |actual|
    msg = "expected that #{actual.inspect} would be a successfull result"
    if actual.success?
      ::RSpec::Expectations.fail_with("#{msg} and matching payload", expected, actual.payload)
    else
      msg
    end
  end
end
