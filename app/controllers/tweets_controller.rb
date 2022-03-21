class TweetsController < ApplicationController
  before_action :set_tweet, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[index show]

  # GET /tweets or /tweets.json
  def index
    @tweets = Tweet.all.includes(:likeables).reverse
    @user_gid = current_user.to_gid_param if current_user
  end

  # GET /tweets/1 or /tweets/1.json
  def show; end

  # GET /tweets/new
  def new
    @tweet = Tweet.new
  end

  # GET /tweets/1/edit
  def edit; end

  # POST /tweets or /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)

    @tweet.user = current_user
    @tweet.save
  end

  # PATCH/PUT /tweets/1 or /tweets/1.json
  def update
    respond_to do |format|
      if @tweet.update(tweet_params)
        format.html { redirect_to tweet_url(@tweet), notice: 'Tweet was successfully updated.' }
        format.json { render :show, status: :ok, location: @tweet }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets/1 or /tweets/1.json
  def destroy
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url, notice: 'Tweet was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def like
    @tweet = Tweet.find(params[:id])
    current_user.like(@tweet)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: private_stream
      end
    end
  end

  private

  def private_stream
    private_target = "#{helpers.dom_id(@tweet)} private_likes"
    turbo_stream.replace(private_target,
                         partial: 'likes/private_button',
                         locals: {
                           tweet: @tweet,
                           like_status: current_user.liked?(@tweet)
                         })
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_tweet
    @tweet = Tweet.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def tweet_params
    params.require(:tweet).permit(:body)
  end
end
