class PostsController < ApplicationController
  def index
    @posts = Post.all
    fresh_when @posts
  end
end
