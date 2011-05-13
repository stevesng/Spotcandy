require 'spec_helper'

describe "candies/new.html.erb" do
  before(:each) do
    assign(:candy, stub_model(Candy,
      :venue_id => 1,
      :pid => "MyString",
      :data => "MyText"
    ).as_new_record)
  end

  it "renders new candy form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => candies_path, :method => "post" do
      assert_select "input#candy_venue_id", :name => "candy[venue_id]"
      assert_select "input#candy_pid", :name => "candy[pid]"
      assert_select "textarea#candy_data", :name => "candy[data]"
    end
  end
end
