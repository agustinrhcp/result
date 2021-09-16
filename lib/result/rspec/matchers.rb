RSpec::Matchers.define :be_an_ok_result do |expected|
  match do |actual|
    expect(actual).to be_kind_of(Result)
    expect(actual).to be_ok
    expect(actual.when_ok(&:itself).when_error { Unreachable }).to eql expected
  end
end

RSpec::Matchers.define :be_an_error_result do |expected|
  match do |actual|
    expect(actual).to be_kind_of(Result)
    expect(actual).to be_error
    expect(actual.when_ok { Unreachable }.when_error(&:itself)).to eql expected
  end
end
