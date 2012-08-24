class CreateOnlineMeetingMembers < ActiveRecord::Migration
  def self.up
    create_table :online_meeting_members do |t|
      t.integer :member_id
      t.references :online_meeting_room
      t.timestamps
    end
  end

  def self.down
    drop_table :online_meeting_members
  end
end
