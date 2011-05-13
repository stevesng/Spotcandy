require 'spec_helper'

describe "venues/edit.html.erb" do
  before(:each) do
    @venue = assign(:venue, stub_model(Venue,
      :new_record? => false,
      :foursquare_id => 1,
      :data => "MyText"
    ))
  end

  it "renders the edit venue form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => venue_path(@venue), :method => "post" do
      assert_select "input#venue_foursquare_id", :name => "venue[foursquare_id]"
      assert_select "textarea#venue_data", :name => "venue[data]"
    end
  end
end
