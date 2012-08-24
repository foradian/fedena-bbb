ActionController::Routing::Routes.draw do |map|

  map.resources :online_meeting_servers,:member=>{:activity=>:get}
  map.resources :online_meeting_rooms,:member=>{:join=>[:get],:auth=>:post,:running=>:post,:end_meeting=>:get,:invite=>:get},
    :collection=>{:view_meetings_by_date=>[:get,:post],:update_recipient_list=>[:get,:post],:to_schools=>[:get,:post],:to_students=>[:get,:post],:to_employees=>[:get,:post],\
      :select_users=>[:get,:post],:select_student_course=>[:get,:post],:select_employee_department=>[:get,:post]}
   
end

