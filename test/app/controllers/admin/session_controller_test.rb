require "test_helper"

=begin

  What's being tested here?

    - Sessions

=end

class Admin::SessionControllerTest < ActionController::TestCase

  context "Setup" do

    should "redirect_to_new_admin_account_when_no_admin_users" do
      get :new
      assert_response :redirect
      assert_redirected_to new_admin_account_path
    end

  end

  context "With users" do

    setup do
      @typus_user = Factory(:typus_user)
    end

    should "render new" do
      get :new
      assert_response :success
    end

    should "render new and verify title and header" do
      get :new
      assert_select "title", "Typus &mdash; Sign in"
      assert_select "h1", "Typus"
    end

    should "render session layout" do
      get :new
      assert_template "new"
      assert_template "layouts/admin/session"
    end

    should "verify_typus_sign_in_layout_does_not_include_recover_password_link" do
      get :new
      assert !@response.body.include?("Recover password")
    end

    should "verify new includes recover_password_link when mailer_sender is set" do
      Typus.expects(:mailer_sender).returns("john@example.com")
      get :new
      assert @response.body.include?("Recover password")
    end

    should "not_create_session_for_invalid_users" do
      post :create, { :typus_user => { :email => "john@example.com", :password => "XXXXXXXX" } }
      assert_response :redirect
      assert_redirected_to new_admin_session_path
    end

    should "not_create_session_for_a_disabled_user" do
      typus_user = Factory(:typus_user, :email => "disabled@example.com", :status => false)

      post :create, { :typus_user => { :email => typus_user.email, :password => "12345678" } }

      assert_nil @request.session[:typus_user_id]
      assert_response :redirect
      assert_redirected_to new_admin_session_path
    end

    should "create_session_for_an_enabled_user" do
      post :create, { :typus_user => { :email => @typus_user.email, :password => "12345678" } }

      assert_equal @typus_user.id, @request.session[:typus_user_id]
      assert_response :redirect
      assert_redirected_to admin_dashboard_path
    end

    should "create_session_for_an_enabled_user_and_redirect_to_home" do
      orig_admin = Typus.post_login_to_admin
      orig_route = Typus.post_login_route
      Typus.post_login_to_admin = "only_some_other_role"
      Typus.post_login_route    = "/"

      post :create, { :typus_user => { :email => @typus_user.email, :password => "12345678" } }

      assert_equal @typus_user.id, @request.session[:typus_user_id]
      assert_response :redirect
      assert_redirected_to '/'

      Typus.post_login_to_admin = orig_admin
      Typus.post_login_route    = orig_route
    end

    should "create_session_for_an_enabled_user_and_redirect_to_dashboard" do
      orig_admin = Typus.post_login_to_admin
      orig_route = Typus.post_login_route
      Typus.post_login_to_admin = "one, #{@typus_user.role},another"
      Typus.post_login_route    = "/"

      post :create, { :typus_user => { :email => @typus_user.email, :password => "12345678" } }

      assert_equal @typus_user.id, @request.session[:typus_user_id]
      assert_response :redirect
      assert_redirected_to admin_dashboard_path

      Typus.post_login_to_admin = orig_admin
      Typus.post_login_route    = orig_route
    end

    should "destroy" do
      delete :destroy

      assert_nil @request.session[:typus_user_id]
      assert_response :redirect
      assert_redirected_to new_admin_session_path
      assert flash.empty?
    end

  end

end
