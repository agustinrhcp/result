class Result::Ok
  def initialize(value)
    @value = value
  end

  def extract
    @value
  end
end
