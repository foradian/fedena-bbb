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
ActionController::Routing::Routes.draw do |map|

  map.resources :online_meeting_servers,:member=>{:activity=>:get}
  map.resources :online_meeting_rooms,:member=>{:join=>[:get],:auth=>:post,:running=>:post,:end_meeting=>:get,:invite=>:get},
    :collection=>{:view_meetings_by_date=>[:get,:post],:update_recipient_list=>[:get,:post],:to_schools=>[:get,:post],:to_students=>[:get,:post],:to_employees=>[:get,:post],\
      :select_users=>[:get,:post],:select_student_course=>[:get,:post],:select_employee_department=>[:get,:post]}
   
end

