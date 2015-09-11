require 'spec_helper'

describe Friendship do

  let!( :user ) { FactoryGirl.create( :user ) }
  let!( :other_user ) { FactoryGirl.create( :user, :email => "other." + user.email  ) }

  it 'require two users' do

    friendship = Friendship.new

    friendship.save.should be_false
    friendship.errors[:user_id].should_not be_empty
    friendship.errors[:friend_id].should_not be_empty

    friendship.user_id = user.id
    friendship.friend_id = nil
    friendship.save.should be_false
    friendship.errors[:user_id].should be_empty
    friendship.errors[:friend_id].should_not be_empty

    friendship.user_id = nil
    friendship.friend_id = other_user.id
    friendship.save.should be_false
    friendship.errors[:user_id].should_not be_empty
    friendship.errors[:friend_id].should be_empty

    friendship.user_id = user.id
    friendship.friend_id = user.id
    friendship.save.should be_false
    friendship.errors[:friend_id].should_not be_empty

    friendship.user_id = user.id
    friendship.friend_id = other_user.id
    friendship.save.should be_true
    friendship.errors[:user_id].should be_empty
    friendship.errors[:friend_id].should be_empty
  end

  it 'should not allow multiple friendships of the same friend' do
    friendship = Friendship.new(
      :user_id => user.id,
      :friend_id => other_user.id
    )
    friendship.save.should be_true

    other_friendship = Friendship.new(
      :user_id => user.id,
      :friend_id => other_user.id
    )
    other_friendship.save.should be_false
    other_friendship.errors[:user_id].should_not be_empty

    other_friendship = Friendship.new(
      :user_id => other_user.id,
      :friend_id => user.id
    )
    other_friendship.save.should be_false
    other_friendship.errors[:user_id].should_not be_empty
  end

  it 'should properly mark new friendships as not accepted' do
    friendship = Friendship.new(
      :user_id => user.id,
      :friend_id => other_user.id
    )

    friendship.save.should be_true
    friendship.reload
    friendship.accepted.should be_false
  end

  it 'should properly associate with users and friends' do
    friendship = Friendship.create(
      :user_id => user.id,
      :friend_id => other_user.id
    )

    friendship.user.id.should eql user.id
    friendship.friend.id.should eql other_user.id
  end
end
