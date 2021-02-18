class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]
  before_action :authenticate_user!, only: [:edit, :update, :destroy]

  def index
    @articles = Article.all
  end

  def show
    @user = User.find_by(id: @article.user_id)
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    if @article.save
      redirect_to(article_url(@article.id))
    else
      render 'articles/new'
    end
  end

  def edit
    @article = Article.find_by(id: params[:id])
    if @article.user_id != current_user.id
      flash[:notice] = "Not yours"
      redirect_to '/'
    end
  end

  def update
    @article = Article.find_by(id: params[:id])
    if @article.user_id == current_user.id
      @article.update(article_params)
      @article.save
      redirect_to(article_url(@article.id))
    end
  end

  def destroy
    @article = Article.find_by(id: params[:id])
    if @article.user_id == current_user.id
      @article.destroy
      REDIS.zrem('ranking', article.title)
      redirect_to '/'
    else
      flash[:notice] = "Not yours"
      redirect_to '/'
    end
  end

  private
  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content).merge(user_id: current_user.id)
  end
end