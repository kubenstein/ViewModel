require '../view_model.rb'
require './spec_helper.rb'

#######################################################
module Reports
  class SpecViewModel < ViewModel::Base
   declared_params :user, :report_id

    def view_params
      {
          report: report,
          user: params[:user],
      }
    end

    def display_formatted_header(user, bold = true)
      text = bold ? "<b> #{user.email} </b>" : user.email
      text.html_safe
    end


    private

    def report
      OpenStruct.new(id: params[:report_id], dummy: :yes)
    end

  end
end
#######################################################


RSpec.describe ViewModel do
  subject { Reports::SpecViewModel }
  let(:render_delegate) { view_renderer }

  it 'sets proper view params' do
    view_model = subject.new(render_delegate, user: 'user', report_id: 777, extra: :should_no_be_there)
    expect(view_model.view_params[:user]).to eq 'user'
    expect(view_model.view_params[:report].id).to eq 777
    expect(view_model.view_params[:extra]).to eq nil
  end

  it 'sets proper default template, format, layout and status' do
    view_model = subject.new(render_delegate)
    expect(view_model.render_params[:layout]).to eq nil
    expect(view_model.render_params[:formats]).to eq [:html]
    expect(view_model.render_params[:status]).to eq :ok
    expect(view_model.render_params[:template]).to eq 'reports/spec_view_model'
  end

  it 'sets proper view locals' do
    report = OpenStruct.new(id: 777, dummy: :yes)
    view_model = subject.new(render_delegate, user: 'user', report_id: 777)

    locals = view_model.render_params[:locals]

    expect(locals[:report]).to eq report
    expect(locals[:user]).to eq 'user'
    expect(locals[:_]).to eq view_model
    expect(locals[:params]).to eq({
          :report => report,
          :user => 'user'
    })
  end

  it 'renders template as it should be rendered' do
    user = OpenStruct.new(email: 'abc@abc.com')
    view_model = subject.new(render_delegate, user: user, report_id: 777)

    html = view_model.call
    expect(html).to eq "
<h1><b> abc@abc.com </b></h1>
<h2>abc@abc.com</h2>
<p>777</p>
<p>yes</p>"
  end

end