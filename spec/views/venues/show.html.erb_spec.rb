require 'spec_helper'

describe "venues/show.html.erb" do
  before(:each) do
    @venue = assign(:venue, stub_model(Venue,
      :foursquare_id => 1,
      :data => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
