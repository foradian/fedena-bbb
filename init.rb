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
require File.join(File.dirname(__FILE__), "lib", "fedena_bigbluebutton")

FedenaPlugin.register = {
  :name=>"fedena_bigbluebutton",
  :description=>"Fedena Module to integrate with BigBlueButton",
  :auth_file=>"config/online_meetings_auth.rb",
  :more_menu=>{:title=>"collaborate_text",:controller=>"online_meeting_rooms",:action=>"index",:target_id=>"more-parent"},
  :multischool_models=>%w{OnlineMeetingServer OnlineMeetingRoom OnlineMeetingMember }
}

Dir[File.join("#{File.dirname(__FILE__)}/config/locales/*.yml")].each do |locale|
  I18n.load_path.unshift(locale)
end
