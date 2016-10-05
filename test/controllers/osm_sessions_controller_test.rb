require 'test_helper'

class OsmSessionsControllerTest < ActionController::TestCase
  setup do
    @osm_session = osm_sessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:osm_sessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create osm_session" do
    assert_difference('OsmSession.count') do
      post :create, osm_session: {  }
    end

    assert_redirected_to osm_session_path(assigns(:osm_session))
  end

  test "should show osm_session" do
    get :show, id: @osm_session
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @osm_session
    assert_response :success
  end

  test "should update osm_session" do
    patch :update, id: @osm_session, osm_session: {  }
    assert_redirected_to osm_session_path(assigns(:osm_session))
  end

  test "should destroy osm_session" do
    assert_difference('OsmSession.count', -1) do
      delete :destroy, id: @osm_session
    end

    assert_redirected_to osm_sessions_path
  end
end
