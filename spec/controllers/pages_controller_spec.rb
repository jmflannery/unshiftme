require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'about'" do

    it "should be successful" do
      get 'about'
      response.should be_success
    end

    it "should have the right title" do
      get 'about'
      response.body.should have_selector("title", :content => "About")
    end
  end

  describe "GET 'feautures'" do

    it "should be successful" do
      get 'features'
      response.should be_success
    end

    it "should have the right title" do
      get 'features'
      response.body.should have_selector("title", :content => "Features")
    end
  end

  describe "GET 'technology'" do

    it "should be successful" do
      get 'technology'
      response.should be_success
    end

    it "should have the right title" do
      get 'technology'
      response.body.should have_selector("title", :content => "Technology")
    end
  end
end

