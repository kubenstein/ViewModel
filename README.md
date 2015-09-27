# ViewModel (POC)

ViewModel is experimental, super simple view layer for Rails heavy inspired by idea of [Cells](https://github.com/apotonick/cells).

ViewModel is still POC so go for Cells if you want serious, production ready solutions.


## Idea
Main idea is to introduce some sort of class that is responsible for all logic related with view layer, such as:

* rendering templates
* preparing data
* providing helpers methods / decorating input by view-related logic

ViewModel is just an ordinary ruby class. You can call any ViewModel class inside of any template, dividing logic into reusable 'Cells'.

## Usage
ViewModel delegates `render` method to controller, so for now, on initialization you have to pass controller or `_` as first param. Calling `call` method on ViewModel object starts rendering pipeline.

app/controllers/reports_controller.rb:

```ruby

class ReportsController < ApplicationController

  def show
    Report::Show::View.new(self, user: current_user, report_id: params[:id]).call
  end

end


```

app/views/report/show/view.rb:

```ruby

class Report::Show::View < ViewModel::Base
 declared_params :user, :report_id

  def view_params
    {
        report: report,
        new_report: Report.new
    }
  end

  def display_formatted_header(user, bold = true)
    text = bold ? "<b> #{user.email} </b>" : user.email
    text.html_safe
  end


  private

  def report
    params[:user].scrap_requests.find(params[:report_id])
  end

end


```


app/views/report/show/view.html.slim:

```ruby

h1 = _.display_formatted_header(user)

strong Title of the Report:
span = report.name
or
span = params[:report].name

h3.normal-header = _.display_formatted_header(user, false)

.form
  = Report::Form::View.new(_, report: new_report).call


```


## declared_params
`declared_params` is a list of allowed params that ViewModel class will have under `params` hash. It is filtered list from all incoming params. Only `layout` and `format` params are allowed without explicit need for declare them.

## view_params
`view_params` is a method that returns hash of all variables visible in the template. It is translated to locals `render` param.
If `view_params` is not overwritten in your ViewModel class, it will return empty hash.

## format, layout, status, template_path
Those methods can be overwritten for more specyfic needs. It directly maps to `render` params.

- Default format is `html`
- Layout param is skipped by default
- Default status is `:ok`
- Default template_path is `view(.format)(.preprocesor)` in same directory as ViewModel

## _
`_` is ViewModel object itself. It is useful for accessing ViewModel public methods a.k.a. Helpers or passing view_context to nested ViewModels.

## Testing
Since ViewModels are just ruby objects you can test proper parameters manipulation by simply:

```ruby
it 'returns proper parameters' do
  view_model = subject.new(view_renderer, user: user, some_other_param: 1)
  expect(view_model.view_params[:report]).to eq report
end
```

### Tests: view_renderer
To test ViewModel rendered template, you need to pass Rails controller `view_context` as a first param.
The Easiest way to do this in tests, is by creating dummy ActionController:


```ruby
#
# Dummy Controller with working render template func
# based on: https://github.com/rails/rails/issues/18409
#
def view_renderer
  ApplicationController.new.tap do |controller|
    controller.request = ActionDispatch::Request.new('HTTP_HOST' => 'example.com',
                                                     'SCRIPT_NAME' => '',
                                                     'HTTPS' => 'off',
                                                     'rack.input' => ''
    )
    controller.response = ActionDispatch::Response.new

    def controller.render(args)
      super(args)[0].to_str
    end
  end
end

```

So test can look like this:

```ruby
it 'returns proper html' do
  body = subject.new(view_renderer, user: user).call
  expect(body).to eq ...
end

it 'returns proper json' do
  body = subject.new(view_renderer, user: user, format: :json).call
  json = JSON.parse(body)
  expect(json).to eq({
    reports: [
        #...
    ]
  })
end

```


