RSpec::Matchers.define :have_json_response do |expected|
  match do |actual|
    @actual = JSON.parse(actual.body, symbolize_names: true)
    match(expected).matches?(@actual)
  end

  failure_message do |actual|
    msg = "expected that #{actual.inspect} to have json response #{expected.inspect}"
    ::RSpec::Expectations.fail_with(msg, expected, actual)
  end
end
