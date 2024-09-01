# spec/lib/result_spec.rb

require 'rails_helper'

RSpec.describe Result do
  describe '.success' do
    it 'creates a successful result' do
      result = Result.success('Success value')

      expect(result).to be_success
      expect(result).not_to be_failure
      expect(result.value).to eq('Success value')
      expect(result.error).to be_nil
    end

    it 'creates a successful result without a value' do
      result = Result.success

      expect(result).to be_success
      expect(result.value).to be_nil
    end
  end

  describe '.failure' do
    it 'creates a failed result' do
      result = Result.failure('Something went wrong')

      expect(result).to be_failure
      expect(result).not_to be_success
      expect(result.error).to eq('Something went wrong')
      expect(result.value).to be_nil
    end
  end

  describe '#success?' do
    it 'returns true for a successful result' do
      result = Result.success

      expect(result.success?).to be true
    end

    it 'returns false for a failed result' do
      result = Result.failure('Error')

      expect(result.success?).to be false
    end
  end

  describe '#failure?' do
    it 'returns true for a failed result' do
      result = Result.failure('Error')

      expect(result.failure?).to be true
    end

    it 'returns false for a successful result' do
      result = Result.success

      expect(result.failure?).to be false
    end
  end
end
