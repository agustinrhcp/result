class Result
  def initialize(result)
    @result = result
  end

  def self.ok(successful_thing)
    new(Ok.new(successful_thing))
  end

  def self.error(errored_thing)
    new(Err.new(errored_thing))
  end

  def map
    case @result
    when Ok
      self.class.ok(yield @result.extract)
    when Err
      self
    end
  end

  def then
    case @result
    when Ok
      yield(@result.extract).tap do |returned_result|
        unless returned_result.is_a?(self.class)
          raise InvalidReturn, 'then handler must return a Result'
        end
      end
    when Err
      self
    end
  end

  def map_error
    case @result
    when Err
      self.class.error(yield @result.extract)
    when Ok
      self
    end
  end

  def ok?
    @result.is_a?(Ok)
  end

  def error?
    @result.is_a?(Err)
  end

  def when_ok(&block)
    Case.when_ok(self, &block)
  end

  def self.combine_map(list)
    list.reduce(self.ok []) do |acc, item|
      break acc if acc.error?

      result = yield item

      map2(acc, result) do |acc_list, result_item|
        acc_list + [result_item]
      end
    end
  end

  def self.map2(first_result, second_result)
    first_result.then do |first|
      second_result.then do |second|
        self.ok yield first, second
      end
    end
  end

  private

  def _result
    @result
  end
end

require 'result/case'
require 'result/err'
require 'result/errors'
require 'result/ok'
