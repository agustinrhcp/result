class Result::With
  def initialize(block:)
    @blocks = [block]
  end

  def and(&block)
    @blocks << block
    self
  end

  def then
    run.then do |results|
      yield *results
    end
  end

  def when_ok
    run.when_ok do |results|
      yield *results
    end
  end

  def map
    run.map do |results|
      yield *results
    end
  end

  private

  def run
    Result.combine_map(@blocks, &:call)
  end
end
