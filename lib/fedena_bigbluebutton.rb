require "translator"
require File.join(File.dirname(__FILE__), "big_blue_button")
require File.join(File.dirname(__FILE__), "bigbluebutton_attendee")
require File.join(File.dirname(__FILE__), "hash_to_xml")

User.send :has_many, :online_meeting_members, :foreign_key=>:member_id
User.send :has_many, :online_meeting_rooms, :through=>:online_meeting_members

class FedenaBigbluebutton
  
end