require 'test_helper'

class FacebooksControllerTest < ActionController::TestCase
  setup do
    @facebook = facebooks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:facebooks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create facebook" do
    assert_difference('Facebook.count') do
      post :create, facebooks: {  }
    end

    assert_redirected_to facebook_path(assigns(:facebooks))
  end

  test "should show facebook" do
    get :show, id: @facebook
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @facebook
    assert_response :success
  end

  test "should update facebook" do
    patch :update, id: @facebook, facebooks: {  }
    assert_redirected_to facebook_path(assigns(:facebooks))
  end

  test "should destroy facebook" do
    assert_difference('Facebook.count', -1) do
      delete :destroy, id: @facebook
    end

    assert_redirected_to facebooks_path
  end
end
