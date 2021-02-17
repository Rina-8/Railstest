class ArticlesController < ApplicationController
  before_action :set_article, only: [:show]


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

  private
  def set_article
    @article = Article.find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :content).merge(user_id: current_user.id)
  end
end
