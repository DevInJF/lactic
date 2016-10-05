require 'test_helper'

class LActicMatchesControllerTest < ActionController::TestCase
  setup do
    @l_actic_match = l_actic_matches(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:l_actic_matches)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create l_actic_match" do
    assert_difference('LActicMatch.count') do
      post :create, l_actic_match: { requestor: @l_actic_match.requestor, responder: @l_actic_match.responder, status: @l_actic_match.status }
    end

    assert_redirected_to l_actic_match_path(assigns(:l_actic_match))
  end

  test "should show l_actic_match" do
    get :show, id: @l_actic_match
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @l_actic_match
    assert_response :success
  end

  test "should update l_actic_match" do
    patch :update, id: @l_actic_match, l_actic_match: { requestor: @l_actic_match.requestor, responder: @l_actic_match.responder, status: @l_actic_match.status }
    assert_redirected_to l_actic_match_path(assigns(:l_actic_match))
  end

  test "should destroy l_actic_match" do
    assert_difference('LActicMatch.count', -1) do
      delete :destroy, id: @l_actic_match
    end

    assert_redirected_to l_actic_matches_path
  end
end
