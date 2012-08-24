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
