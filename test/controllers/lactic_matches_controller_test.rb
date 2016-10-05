require 'test_helper'

class LacticMatchesControllerTest < ActionController::TestCase
  setup do
    @lactic_match = lactic_matches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lactic_matches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lactic_match" do
    assert_difference('LacticMatch.count') do
      post :create, lactic_match: { requestor: @lactic_match.requestor, responder: @lactic_match.responder, status: @lactic_match.status }
    end

    assert_redirected_to lactic_match_path(assigns(:lactic_match))
  end

  test "should show lactic_match" do
    get :show, id: @lactic_match
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lactic_match
    assert_response :success
  end

  test "should update lactic_match" do
    patch :update, id: @lactic_match, lactic_match: { requestor: @lactic_match.requestor, responder: @lactic_match.responder, status: @lactic_match.status }
    assert_redirected_to lactic_match_path(assigns(:lactic_match))
  end

  test "should destroy lactic_match" do
    assert_difference('LacticMatch.count', -1) do
      delete :destroy, id: @lactic_match
    end

    assert_redirected_to lactic_matches_path
  end
end
