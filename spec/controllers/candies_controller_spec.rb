require 'spec_helper'

describe CandiesController do

  def mock_candy(stubs={})
    (@mock_candy ||= mock_model(Candy).as_null_object).tap do |candy|
      candy.stub(stubs) unless stubs.empty?
    end
  end

  describe "GET index" do
    it "assigns all candies as @candies" do
      Candy.stub(:all) { [mock_candy] }
      get :index
      assigns(:candies).should eq([mock_candy])
    end
  end

  describe "GET show" do
    it "assigns the requested candy as @candy" do
      Candy.stub(:find).with("37") { mock_candy }
      get :show, :id => "37"
      assigns(:candy).should be(mock_candy)
    end
  end

  describe "GET new" do
    it "assigns a new candy as @candy" do
      Candy.stub(:new) { mock_candy }
      get :new
      assigns(:candy).should be(mock_candy)
    end
  end

  describe "GET edit" do
    it "assigns the requested candy as @candy" do
      Candy.stub(:find).with("37") { mock_candy }
      get :edit, :id => "37"
      assigns(:candy).should be(mock_candy)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created candy as @candy" do
        Candy.stub(:new).with({'these' => 'params'}) { mock_candy(:save => true) }
        post :create, :candy => {'these' => 'params'}
        assigns(:candy).should be(mock_candy)
      end

      it "redirects to the created candy" do
        Candy.stub(:new) { mock_candy(:save => true) }
        post :create, :candy => {}
        response.should redirect_to(candy_url(mock_candy))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved candy as @candy" do
        Candy.stub(:new).with({'these' => 'params'}) { mock_candy(:save => false) }
        post :create, :candy => {'these' => 'params'}
        assigns(:candy).should be(mock_candy)
      end

      it "re-renders the 'new' template" do
        Candy.stub(:new) { mock_candy(:save => false) }
        post :create, :candy => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested candy" do
        Candy.should_receive(:find).with("37") { mock_candy }
        mock_candy.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :candy => {'these' => 'params'}
      end

      it "assigns the requested candy as @candy" do
        Candy.stub(:find) { mock_candy(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:candy).should be(mock_candy)
      end

      it "redirects to the candy" do
        Candy.stub(:find) { mock_candy(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(candy_url(mock_candy))
      end
    end

    describe "with invalid params" do
      it "assigns the candy as @candy" do
        Candy.stub(:find) { mock_candy(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:candy).should be(mock_candy)
      end

      it "re-renders the 'edit' template" do
        Candy.stub(:find) { mock_candy(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested candy" do
      Candy.should_receive(:find).with("37") { mock_candy }
      mock_candy.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the candies list" do
      Candy.stub(:find) { mock_candy }
      delete :destroy, :id => "1"
      response.should redirect_to(candies_url)
    end
  end

end
