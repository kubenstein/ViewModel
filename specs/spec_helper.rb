require 'action_controller'
#
# Dummy Controller with working render template func
# based on: https://github.com/rails/rails/issues/18409
#
def view_renderer
  ActionController::Base.new.tap do |controller|
    controller.request = ActionDispatch::Request.new('HTTP_HOST' => 'example.com',
                                                     'SCRIPT_NAME' => '',
                                                     'HTTPS' => 'off',
                                                     'rack.input' => ''
    )
    controller.response = ActionDispatch::Response.new
    controller.class.prepend_view_path '.'

    def controller.render(args)
      super(args)[0].to_str
    end
  end
end