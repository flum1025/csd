require 'test_helper'

class ServersControllerTest < ActionController::TestCase
  test "should get statues" do
    get :statues
    assert_response :success
  end

end
