require 'spec_helper'

describe "venues/new.html.erb" do
  before(:each) do
    assign(:venue, stub_model(Venue,
      :foursquare_id => 1,
      :data => "MyText"
    ).as_new_record)
  end

  it "renders new venue form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => venues_path, :method => "post" do
      assert_select "input#venue_foursquare_id", :name => "venue[foursquare_id]"
      assert_select "textarea#venue_data", :name => "venue[data]"
    end
  end
end
