require 'rails_helper'

RSpec.describe "projects/show", type: :view, pending: 'We will not test views' do
  before(:each) do
    @project = assign(:project, Project.create!(
      :name => "Name",
      :description => "MyText",
      :owner_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
    expect(rendered).to match(/1/)
  end
end
