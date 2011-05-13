require 'spec_helper'

describe "photos/edit.html.erb" do
  before(:each) do
    @photo = assign(:photo, stub_model(Photo,
      :new_record? => false,
      :candy_id => 1,
      :photo_file_name => "MyString",
      :photo_content_type => "MyString",
      :photo_file_size => 1
    ))
  end

  it "renders the edit photo form" do
    render

    # Run the generator again with the --webrat-matchers flag if you want to use webrat matchers
    assert_select "form", :action => photo_path(@photo), :method => "post" do
      assert_select "input#photo_candy_id", :name => "photo[candy_id]"
      assert_select "input#photo_photo_file_name", :name => "photo[photo_file_name]"
      assert_select "input#photo_photo_content_type", :name => "photo[photo_content_type]"
      assert_select "input#photo_photo_file_size", :name => "photo[photo_file_size]"
    end
  end
end
