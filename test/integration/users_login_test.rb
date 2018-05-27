require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # get valid user fixture
  def setup
    @user = users(:michael)
  end

  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: {session: {email: "", password: ""} }
    assert_template 'sessions/new'
    assert_not flash.empty?     # flash is not empty
    get root_path        
    assert flash.empty?
  end

  test 'login with valid information followed by logout' do
    get login_path              #visit the login path 
    post login_path, params: {session: {email: @user.email, 
                                        password: 'password' }}   #post valid infromation to the sessions path
    assert_redirected_to @user        # verify that the right redirect target
    follow_redirect!                # visit the target page
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0    # verify that the login link disappears
    assert_select 'a[href=?]', logout_path        # verify that a logout link appears
    assert_select 'a[href=?]', user_path(@user)   # verify that a profile link appears

    delete logout_path 
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select 'a[href=?]', login_path   
    assert_select 'a[href=?]', logout_path, count: 0       
    assert_select 'a[href=?]', user_path(@user), count: 0 
  end
end
