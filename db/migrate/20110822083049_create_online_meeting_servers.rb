class CreateOnlineMeetingServers < ActiveRecord::Migration
 def self.up
  create_table :online_meeting_servers do |t|
      t.string :name
      t.string :url
      t.string :salt
      t.string :version
      t.string :param
      t.timestamps
   end
 end

 def self.down
   drop_table :online_meeting_servers
 end
end
