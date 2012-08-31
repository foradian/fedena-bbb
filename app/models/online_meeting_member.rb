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
class OnlineMeetingMember < ActiveRecord::Base
  belongs_to :online_meeting_room, :foreign_key => :online_meeting_room_id
  belongs_to :member,:class_name=>"User"
  validates_uniqueness_of :member_id, :scope => :online_meeting_room_id, :message => "#{t('should_be_included_only_once')}"
end
