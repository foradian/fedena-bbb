class CreateOnlineMeetingRooms < ActiveRecord::Migration
  def self.up
    create_table :online_meeting_rooms do |t|
      t.integer :server_id
      t.integer :user_id
      t.string :meetingid
      t.string :name
      t.string :attendee_password
      t.string :moderator_password
      t.string :welcome_msg
      t.string :logout_url
      t.string :voice_bridge
      t.string :dial_number
      t.integer :max_participants
      t.boolean :private, :default => false
      t.boolean :randomize_meetingid, :default => true
      t.boolean :external, :default => false
      t.string :param
      t.datetime :scheduled_on
      t.boolean :is_active,:default=>true
      t.timestamps
    end
    add_index :online_meeting_rooms, :server_id
    add_index :online_meeting_rooms, :meetingid, :unique => true
    add_index :online_meeting_rooms, :voice_bridge, :unique => true
  end

  def self.down
    drop_table :online_meeting_rooms
  end
end
