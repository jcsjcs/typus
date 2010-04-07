require 'test/helper'

class AdminHelperTest < ActiveSupport::TestCase

  include AdminHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionController::UrlWriter

  def render(*args); args; end

  def test_page_title
    @page_title = ["a", "b"]
    options = { :app_name => 'whatistypus.com' }
    Typus::Configuration.stubs(:options).returns(options)
    assert_equal 'whatistypus.com - a &rsaquo; b', page_title
  end

  def test_header_with_root_path

    # Add root named route
    ActionController::Routing::Routes.add_named_route :root, "/", { :controller => "posts" }

    # ActionView::Helpers::UrlHelper does not support strings, which are returned by named routes
    # link root_path
    self.stubs(:link_to).returns(%(<a href="/">View site</a>))
    self.stubs(:link_to_unless_current).returns(%(<a href="/admin/dashboard">Dashboard</a>))

    output = header

    partial = "admin/helpers/header"
    options = { :links => [ "<a href=\"/admin/dashboard\">Dashboard</a>",
                            "<a href=\"/admin/dashboard\">Dashboard</a>", 
                            "<a href=\"/\">View site</a>" ] }

    assert_equal [ partial, options ], output

  end

  # TODO: Clean
  def test_header_without_root_path

    # Remove root route from list
    ActionController::Routing::Routes.named_routes.routes.reject! { |key, route| key == :root }

    self.stubs(:link_to_unless_current).returns(%(<a href="/admin/dashboard">Dashboard</a>))

    output = header
    partial = "admin/helpers/header"
    options = { :links => [ "<a href=\"/admin/dashboard\">Dashboard</a>",
                            "<a href=\"/admin/dashboard\">Dashboard</a>" ] }

    assert_equal [ partial, options ], output

  end

  def test_display_flash_message

    message = { :test => 'This is the message.' }

    output = display_flash_message(message)

    partial = "admin/helpers/flash_message"
    options = { :flash_type => :test, 
                :message => { :test => 'This is the message.' } }

    assert_equal [ partial, options ], output

  end

  def test_display_flash_message_with_empty_message
    message = {}
    output = display_flash_message(message)
    assert output.nil?
  end

end