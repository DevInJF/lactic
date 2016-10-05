require 'test_helper'

class OsmSubscribersControllerTest < ActionController::TestCase
  setup do
    @osm_subscriber = osm_subscribers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:osm_subscribers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create osm_subscriber" do
    assert_difference('OsmSubscriber.count') do
      post :create, osm_subscriber: {  }
    end

    assert_redirected_to osm_subscriber_path(assigns(:osm_subscriber))
  end

  test "should show osm_subscriber" do
    get :show, id: @osm_subscriber
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @osm_subscriber
    assert_response :success
  end

  test "should update osm_subscriber" do
    patch :update, id: @osm_subscriber, osm_subscriber: {  }
    assert_redirected_to osm_subscriber_path(assigns(:osm_subscriber))
  end

  test "should destroy osm_subscriber" do
    assert_difference('OsmSubscriber.count', -1) do
      delete :destroy, id: @osm_subscriber
    end

    assert_redirected_to osm_subscribers_path
  end
end
