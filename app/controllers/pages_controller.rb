class PagesController < ApplicationController

  def about
    @title = "About"
  end

  def features
    @title = "Features"
  end

  def technology
    @title = "Technology"
  end

end

