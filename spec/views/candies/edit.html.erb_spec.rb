require 'spec_helper'

describe "candies/edit.html.erb" do
  before(:each) do
    @candy = assign(:candy, stub_model(Candy,
      :new_record? => false,
      :venue_id => 1,
      :pid => "MyString",
      :data => "MyText"
    ))
  end

  it "renders the edit candy form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => candy_path(@candy), :method => "post" do
      assert_select "input#candy_venue_id", :name => "candy[venue_id]"
      assert_select "input#candy_pid", :name => "candy[pid]"
      assert_select "textarea#candy_data", :name => "candy[data]"
    end
  end
end
