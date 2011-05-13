require "spec_helper"

describe CandiesController do
  describe "routing" do

    it "recognizes and generates #index" do
      { :get => "/candies" }.should route_to(:controller => "candies", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/candies/new" }.should route_to(:controller => "candies", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/candies/1" }.should route_to(:controller => "candies", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/candies/1/edit" }.should route_to(:controller => "candies", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/candies" }.should route_to(:controller => "candies", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/candies/1" }.should route_to(:controller => "candies", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/candies/1" }.should route_to(:controller => "candies", :action => "destroy", :id => "1")
    end

  end
end
