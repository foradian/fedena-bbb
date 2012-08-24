class OnlineMeetingMember < ActiveRecord::Base
  belongs_to :online_meeting_room, :foreign_key => :online_meeting_room_id
  belongs_to :member,:class_name=>"User"
  validates_uniqueness_of :member_id, :scope => :online_meeting_room_id, :message => "#{t('should_be_included_only_once')}"
end
