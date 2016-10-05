require 'test_helper'

class OsmSchedulesControllerTest < ActionController::TestCase
  setup do
    @osm_schedule = osm_schedules(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:osm_schedules)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create osm_schedule" do
    assert_difference('OsmSchedule.count') do
      post :create, osm_schedule: {  }
    end

    assert_redirected_to osm_schedule_path(assigns(:osm_schedule))
  end

  test "should show osm_schedule" do
    get :show, id: @osm_schedule
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @osm_schedule
    assert_response :success
  end

  test "should update osm_schedule" do
    patch :update, id: @osm_schedule, osm_schedule: {  }
    assert_redirected_to osm_schedule_path(assigns(:osm_schedule))
  end

  test "should destroy osm_schedule" do
    assert_difference('OsmSchedule.count', -1) do
      delete :destroy, id: @osm_schedule
    end

    assert_redirected_to osm_schedules_path
  end
end
