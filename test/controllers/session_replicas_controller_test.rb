require 'test_helper'

class SessionReplicasControllerTest < ActionController::TestCase
  setup do
    @session_replica = session_replicas(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:session_replicas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create session_replica" do
    assert_difference('SessionReplica.count') do
      post :create, session_replica: { origin_id: @session_replica.origin_id, start_date: @session_replica.start_date }
    end

    assert_redirected_to session_replica_path(assigns(:session_replica))
  end

  test "should show session_replica" do
    get :show, id: @session_replica
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @session_replica
    assert_response :success
  end

  test "should update session_replica" do
    patch :update, id: @session_replica, session_replica: { origin_id: @session_replica.origin_id, start_date: @session_replica.start_date }
    assert_redirected_to session_replica_path(assigns(:session_replica))
  end

  test "should destroy session_replica" do
    assert_difference('SessionReplica.count', -1) do
      delete :destroy, id: @session_replica
    end

    assert_redirected_to session_replicas_path
  end
end
