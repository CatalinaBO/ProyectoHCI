# frozen_string_literal: true

# SimpleCov (COVERTURA)
require "simplecov"
SimpleCov.start "rails"

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require "active_support/testing/time_helpers"

class ApplicationController
  private
  def require_login; true; end
  def current_user
    Usuario.find_by(email: "usuario@test.cl") || Usuario.first
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    #fixtures :all

    # Add more helper methods to be used by all tests here...
    include ActiveSupport::Testing::TimeHelpers
  end
end

class ActionDispatch::IntegrationTest
  def as_user(user)
    ApplicationController.class_eval do
      define_method(:current_user) { user }
    end
    yield
  ensure
    ApplicationController.class_eval do
      define_method(:current_user) { Usuario.find_by(email: "usuario@test.cl") || Usuario.first }
    end
  end
end

