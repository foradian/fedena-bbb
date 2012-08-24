class AddSchoolIdToBbb < ActiveRecord::Migration
  def self.up
   [:online_meeting_rooms,:online_meeting_servers, :online_meeting_members].each do |c|
      add_column c,:school_id,:integer
      add_index c,:school_id
    end
  end

  def self.down
   [:online_meeting_rooms,:online_meeting_servers, :online_meeting_members].each do |c|
      remove_index c,:school_id
      remove_column c,:school_id,:integer      
    end
  end
end
