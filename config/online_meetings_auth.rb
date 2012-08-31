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
authorization do
  role :admin do
   includes :manage_online_meeting_rooms
   includes :manage_online_meeting_servers
  end

  role :employee do
    includes :manage_online_meeting_rooms
  end

  role :student do
    includes :manage_online_meeting_rooms
  end

  role :manage_online_meeting_servers do
    has_permission_on [:online_meeting_servers],
      :to => [
      :index,:create,:update,:edit,:destroy,:show,:new,:activity]
  end

  role :manage_online_meeting_rooms do
    has_permission_on [:online_meeting_rooms],
      :to => [
      :index,:show,:new,:edit,:create,:update,\
      :destroy,:join,:invite,:auth, :running,\
      :end_meeting, :join_mobile,
      :list_employees,
      :select_employee_department,
      :select_users,
      :select_student_course,
      :select_users,
      :to_employees,
      :to_students,
      :to_schools,
      :update_recipient_list,
      :view_meetings_by_date
      ]

  end

end
