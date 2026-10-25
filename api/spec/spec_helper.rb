# frozen_string_literal: true

RSpec.configure do |config|
  config.example_status_persistence_file_path = nil
  config.expect_with(:rspec) { |expectations| expectations.syntax = :expect }
  config.mock_with(:rspec) { |mocks| mocks.syntax = :expect }
end
