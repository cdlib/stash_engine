module ApplicationHelper
  def main_app
    DummyRoute.new
  end
end

# this is a useless class to make any routes return nothing for main app, essentially ignore the main app which
# is not present
class DummyRoute
  def method_missing(*_args)
    ''
  end
end
