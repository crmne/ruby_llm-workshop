require "application_system_test_case"

class HealthCheckTest < ApplicationSystemTestCase
  test "the app boots in a real browser" do
    visit rails_health_check_path

    assert_selector "body[style*='green']"
  end
end
