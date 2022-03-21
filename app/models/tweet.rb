class Tweet < ApplicationRecord
  has_many :likeables, dependent: :destroy
  has_many :likes, through: :likeables, source: :user
  belongs_to :user

  after_create_commit do
    broadcast_new_tweet
  end
  after_update_commit do
    broadcast_updated_tweet
  end
  after_destroy_commit do
    broadcast_destroy_tweet
  end

  def broadcast_new_tweet
    broadcast_prepend_later_to 'public_tweets',
                               target: 'public_tweets',
                               partial: 'tweets/public_tweet',
                               locals: { tweet: self }
    broadcast_prepend_later_to 'private_tweets',
                               target: 'private_tweets',
                               partial: 'tweets/private_tweet',
                               locals: { tweet: self, like_status: false }
  end

  def broadcast_updated_tweet
    shared_target_tweet = "tweet_#{id}"
    private_target_channel = "#{@user_gid} private_likes"
    broadcast_replace_later_to 'public_tweets',
                               target: shared_target_tweet,
                               partial: 'tweets/public_tweet',
                               locals: { tweet: self }
    broadcast_replace_later_to private_target_channel,
                               target: shared_target_tweet,
                               partial: 'tweets/private_tweet',
                               locals: { tweet: self, like_status: false }
  end

  def broadcast_destroy_tweet
    broadcast_remove_to 'public_tweets',
                        target: "tweet_#{id}"
    broadcast_remove_to 'private_tweets',
                        target: "tweet_#{id}"
  end
end
