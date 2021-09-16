require 'spec_helper'

describe Result do
  describe '.ok' do
    subject { described_class.ok(:ok) }

    it { is_expected.to be_kind_of(described_class) }
    it { is_expected.to be_ok }
  end

  describe '.error' do
    subject { described_class.error(:oops) }

    it { is_expected.to be_kind_of(described_class) }
    it { is_expected.to be_error }
  end

  describe '#map' do
    subject(:mapped) { result.map { |one| one * 2 } }

    context 'mapping over an ok result' do
      let(:result) { described_class.ok(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_ok }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 2 }
      end
    end

    context 'mapping over an error result' do
      let(:result) { described_class.error(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_error }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 1 }
      end
    end
  end

  describe '#then' do
    context 'when the handler does not return a result' do
      subject { ->() { Result.ok(:ok).then(&:itself) } }

      it { is_expected.to raise_error(Result::InvalidReturn) }
    end

    subject(:bound) { result.then { |one| Result.ok(one * 2) } }

    context 'then over an ok result' do
      let(:result) { described_class.ok(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_ok }

      describe 'the inner value' do
        subject { bound.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 2 }
      end


      context 'can return an error' do
        subject(:bound) { result.then { |one| Result.error(:some_error) } }

        it { is_expected.to be_kind_of(described_class) }
        it { is_expected.to be_error }

        describe 'the inner value' do
          subject { bound.when_ok(&:itself).when_error(&:itself) }

          it { is_expected.to be :some_error }
        end
      end
    end

    context 'then over an error result' do
      let(:result) { described_class.error(:some_error) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_error }

      describe 'the inner value' do
        subject { bound.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql :some_error }
      end
    end
  end

  describe '#map_error' do
    subject(:mapped) do
      result.map_error { |error| "Oops: #{error}" }
    end

    context 'mapping over an ok result' do
      let(:result) { Result.ok(1) }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_ok }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql 1 }
      end
    end

    context 'mapping over an error result' do
      let(:result) { Result.error("An error :O") }

      it { is_expected.to be_kind_of(described_class) }
      it { is_expected.to be_error }

      describe 'the inner value' do
        subject { mapped.when_ok(&:itself).when_error(&:itself) }

        it { is_expected.to eql "Oops: An error :O" }
      end
    end
  end

  describe '#when_ok.when_error' do
    let(:result) { Result.ok(:cool) }

    context 'ok result' do
      subject { result.when_ok(&:itself).when_error { :error } }

      it { is_expected.to eql :cool }
    end

    context 'error result' do
      let(:result) { Result.error(:not_cool) }

      subject { result.when_ok { :cool }.when_error(&:itself) }

      it { is_expected.to eql :not_cool }
    end

    describe 'when_ok' do
      subject { result.when_ok(&:itself) }

      it { is_expected.to be_kind_of(Result::Case) }
    end
  end

  describe '.map2' do
    subject do
      Result.map2(Result.ok(2), Result.ok(3)) { |two, three| two + three }
    end

    it { is_expected.to be_an_ok_result(5) }

    context 'with an error' do
      subject do
        Result.map2(Result.ok(2), Result.error(3)) { |two, three| two + three }
      end

      it { is_expected.to be_an_error_result(3) }
    end
  end

  describe '.combine_map' do
    let(:list) { [1, 3, 5] }

    subject do
      Result.combine_map(list) do |n|
        n.odd? ? Result.ok(n) : Result.error(n)
      end
    end

    it { is_expected.to be_ok }
    it { is_expected.to be_an_ok_result([1, 3, 5]) }

    context 'with an error' do
      let(:list) { [2, 3, 5] }

      it { is_expected.to be_an_error_result(2) }
    end
  end
end
