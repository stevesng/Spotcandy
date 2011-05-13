require 'spec_helper'

describe "candies/show.html.erb" do
  before(:each) do
    @candy = assign(:candy, stub_model(Candy,
      :venue_id => 1,
      :pid => "Pid",
      :data => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/Pid/)
    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    rendered.should match(/MyText/)
  end
end
