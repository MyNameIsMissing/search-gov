require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do

  describe "when showing index" do
    it "should have a restful route" do
      searches_path.should == '/searches'
    end

  end

  describe "when showing a new search" do
    before do
      get :index, :queryterm => "social security"
      @search = assigns[:search]
    end

    it "should load results for a keyword query" do
      @search.should_not be_nil
      @search.results.should_not be_nil
    end
  end

end
