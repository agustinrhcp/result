class Result::Case
  def initialize(result, ok_block:)
    @result = result
    @ok_block = ok_block
  end

  def self.when_ok(result, &block)
    new(result, ok_block: block)
  end

  def when_error(&block)
    case @result.send(:_result)
    when Result::Ok
      @ok_block.call(@result.send(:_result).extract)
    when Result::Err
      block.call(@result.send(:_result).extract)
    end
  end
end
