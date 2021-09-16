class Result::Err
  def initialize(value)
    @value = value
  end

  def extract
    @value
  end
end
