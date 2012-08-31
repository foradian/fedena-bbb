#Copyright 2010 Foradian Technologies Private Limited
#This product includes software developed at
#Project Fedena - http://www.projectfedena.org/
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing,
#software distributed under the License is distributed on an
#"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
#KIND, either express or implied.  See the License for the
#specific language governing permissions and limitations
#under the License.
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
