require 'rails_helper'

RSpec.describe "projects/index", type: :view, pending: 'We will not test views'do
  before(:each) do
    assign(:projects, [
      Project.create!(
        :name => "Name",
        :description => "MyText",
        :owner_id => 1
      ),
      Project.create!(
        :name => "Name",
        :description => "MyText",
        :owner_id => 1
      )
    ])
  end

  it "renders a list of projects" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
