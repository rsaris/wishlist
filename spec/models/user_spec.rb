require 'spec_helper'

describe User do
  describe 'Friends' do
    let!(:user) { FactoryGirl.create( :user ) }

    let!(:first_friend) { FactoryGirl.create( :user, :email => 'first@friend.com' ) }
    let!(:second_friend) { FactoryGirl.create( :user, :email => 'second@friend.com' ) }
    let!(:third_friend) { FactoryGirl.create( :user, :email => 'third@friend.com' ) }
    let!(:fourth_friend) { FactoryGirl.create( :user, :email => 'fourth@friend.com' ) }

    it 'should properly grab all regular friends' do
      Friendship.create( :user_id => user.id, :friend_id => first_friend.id )
      Friendship.create( :user_id => user.id, :friend_id => second_friend.id )
      Friendship.create( :user_id => user.id, :friend_id => third_friend.id )
      Friendship.create( :user_id => user.id, :friend_id => fourth_friend.id )
      Friendship.all.each{ |friendship| friendship.update_attribute( :accepted, true ) }

      user.reload
      user.friends.size.should eql 4
      user.friends.map{ |friend| friend.id }.should =~ [first_friend.id, second_friend.id, third_friend.id, fourth_friend.id]
    end

    it 'should properly grab all inverse friends' do
      Friendship.create( :friend_id => user.id, :user_id => first_friend.id )
      Friendship.create( :friend_id => user.id, :user_id => second_friend.id )
      Friendship.create( :friend_id => user.id, :user_id => third_friend.id )
      Friendship.create( :friend_id => user.id, :user_id => fourth_friend.id )
      Friendship.all.each{ |friendship| friendship.update_attribute( :accepted, true ) }

      user.reload
      user.friends.size.should eql 4
      user.friends.map{ |friend| friend.id }.should =~ [first_friend.id, second_friend.id, third_friend.id, fourth_friend.id]
    end

    it 'should join both groups of friends' do
      Friendship.create( :user_id => user.id, :friend_id => first_friend.id )
      Friendship.create( :user_id => user.id, :friend_id => second_friend.id )

      Friendship.create( :friend_id => user.id, :user_id => third_friend.id )
      Friendship.create( :friend_id => user.id, :user_id => fourth_friend.id )
      Friendship.all.each{ |friendship| friendship.update_attribute( :accepted, true ) }

      user.reload
      user.friends.size.should eql 4
      user.friends.map{ |friend| friend.id }.should =~ [first_friend.id, second_friend.id, third_friend.id, fourth_friend.id]
    end

    it 'should ignore friends who have not accepted yet' do
      Friendship.create( :user_id => user.id, :friend_id => first_friend.id )
      Friendship.create( :user_id => user.id, :friend_id => second_friend.id )

      Friendship.create( :friend_id => user.id, :user_id => third_friend.id )
      Friendship.create( :friend_id => user.id, :user_id => fourth_friend.id )
      Friendship.all.each{ |friendship| friendship.update_attribute( :accepted, false ) }

      user.reload
      user.friends.size.should eql 0
    end

    it 'should delete friendships when deleted' do
      Friendship.all.count.should eql 0
      Friendship.create( :user_id => user.id, :friend_id => first_friend.id )
      Friendship.create( :user_id => user.id, :friend_id => second_friend.id )
      Friendship.all.count.should eql 2
      user.destroy
      Friendship.all.count.should eql 0

      user = FactoryGirl.create( :user )
      Friendship.all.count.should eql 0
      Friendship.create( :friend_id => user.id, :user_id => first_friend.id )
      Friendship.create( :friend_id => user.id, :user_id => second_friend.id )
      Friendship.all.count.should eql 2
      user.destroy
      Friendship.all.count.should eql 0
    end
  end
end
