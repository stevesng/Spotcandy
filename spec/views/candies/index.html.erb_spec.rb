require 'spec_helper'

describe "candies/index.html.erb" do
  before(:each) do
    assign(:candies, [
      stub_model(Candy,
        :venue_id => 1,
        :pid => "Pid",
        :data => "MyText"
      ),
      stub_model(Candy,
        :venue_id => 1,
        :pid => "Pid",
        :data => "MyText"
      )
    ])
  end

  it "renders a list of candies" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Pid".to_s, :count => 2
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
