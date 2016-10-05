require 'test_helper'

class LacticSessionsControllerTest < ActionController::TestCase
  setup do
    @lactic_session = lactic_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:lactic_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create lactic_session" do
    assert_difference('LacticSession.count') do
      post :create, lactic_session: { creator_fb_id: @lactic_session.creator_fb_id, description: @lactic_session.description, duration: @lactic_session.duration, end_date_time: @lactic_session.end_date_time, location: @lactic_session.location, location_id: @lactic_session.location_id, shared: @lactic_session.shared, start_date_time: @lactic_session.start_date_time, title: @lactic_session.title, week_day: @lactic_session.week_day }
    end

    assert_redirected_to lactic_session_path(assigns(:lactic_session))
  end

  test "should show lactic_session" do
    get :show, id: @lactic_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @lactic_session
    assert_response :success
  end

  test "should update lactic_session" do
    patch :update, id: @lactic_session, lactic_session: { creator_fb_id: @lactic_session.creator_fb_id, description: @lactic_session.description, duration: @lactic_session.duration, end_date_time: @lactic_session.end_date_time, location: @lactic_session.location, location_id: @lactic_session.location_id, shared: @lactic_session.shared, start_date_time: @lactic_session.start_date_time, title: @lactic_session.title, week_day: @lactic_session.week_day }
    assert_redirected_to lactic_session_path(assigns(:lactic_session))
  end

  test "should destroy lactic_session" do
    assert_difference('LacticSession.count', -1) do
      delete :destroy, id: @lactic_session
    end

    assert_redirected_to lactic_sessions_path
  end
end
