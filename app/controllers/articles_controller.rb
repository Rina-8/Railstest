class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]
  before_action :authenticate_user!, only: [:edit, :update, :destroy]
  before_action :set_ranking_data

  def index
    @articles = Article.all
    @ranking = REDIS.zrevrange "ranking", 0, 2, withscores: true
  end

  def show
    @articles = Article.all
    @user = User.find_by(id: @article.user_id)
    REDIS.zincrby "ranking", 1, "#{@article.id}"
    @ranking = REDIS.zrevrange "ranking", 0, 2, withscores: true
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
      REDIS.zrem "ranking", "#{@article.id}"
      @article.destroy
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

  def set_ranking_data
    ids = REDIS.zrevrangebyscore "articles", "+inf", 0, limit: [0, 3]
    @ranking_articles = ids.map{ |id| Article.find(id) }
    if @ranking_articles.count < 3
      adding_articles = Article.order(updated_at: :DESC).where.not(id: ids).limit(3 - @ranking_articles.count)
      @ranking_articles.concat(adding_articles)
    end
  end
end