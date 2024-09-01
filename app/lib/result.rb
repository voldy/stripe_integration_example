# app/lib/result.rb

# The Result class represents the outcome of an operation, encapsulating both
# success and failure scenarios.
#
# Example usage:
#
#   result = some_operation
#   if result.success?
#     # handle success
#   else
#     # handle failure, e.g., log result.error
#   end
#
class Result
  attr_reader :value, :error

  # Initializes a new Result object.
  #
  # @param success [Boolean] Indicates whether the operation was successful.
  # @param value [Object, nil] The value associated with a successful operation.
  #   Defaults to nil.
  # @param error [String, nil] The error message associated with a failed operation.
  #   Defaults to nil.
  def initialize(success:, value: nil, error: nil)
    @success = success
    @value = value
    @error = error
  end

  # Creates a Result object representing a successful operation.
  #
  # @param value [Object, nil] The value associated with the success.
  # @return [Result] A Result object indicating success.
  def self.success(value = nil)
    new(success: true, value: value)
  end

  # Creates a Result object representing a failed operation.
  #
  # @param error [String] The error message describing the failure.
  # @return [Result] A Result object indicating failure.
  def self.failure(error)
    new(success: false, error: error)
  end

  # Indicates whether the operation was successful.
  #
  # @return [Boolean] true if the operation was successful, false otherwise.
  def success?
    @success
  end

  # Indicates whether the operation failed.
  #
  # @return [Boolean] true if the operation failed, false otherwise.
  def failure?
    !@success
  end
end
