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
class OnlineMeetingRoomsController < ApplicationController
  before_filter :login_required
  before_filter :default_time_zone_present_time
  filter_access_to :all


  #respond_to :html, :except => :running
  #respond_to :json, :only => [:running, :show, :new, :index, :create, :update, :end, :destroy]

  def index
    @date=@local_tzone_time.to_date
    if current_user.admin?
      @rooms = OnlineMeetingRoom.all(:conditions=>"(scheduled_on >= '#{@date.strftime("%Y-%m-%d 00:00:00")}' and scheduled_on <= '#{@date.strftime("%Y-%m-%d 23:59:59")}' )",:order=>"id DESC")
    else
      @rooms = OnlineMeetingRoom.rooms_for_user(current_user,@date)
    end
    @current_user = current_user
  end

  def show
    @room = OnlineMeetingRoom.find_by_id(params[:id])
  end

  def new
    @room = OnlineMeetingRoom.new
    load_data
  end

  def edit
    @room = OnlineMeetingRoom.find_by_id(params[:id])
    @recipients = @room.members
    load_data
  end

  def create
    @room = OnlineMeetingRoom.new(params[:online_meeting_room])
    @room.user_id = current_user.id
    @room.member_ids = params[:recipients].split(",").collect{ |s| s.to_i }
    respond_to do |format|
      if @room.save
        message = t('online_meeting_room_created_successfully')
        format.html {
          params[:redir_url] ||= online_meeting_rooms_path
          flash[:notice] = message
          redirect_to params[:redir_url]
        }
        format.json { render :json => { :message => message }, :status => :created }
      else
        format.html {
          unless params[:redir_url].blank?
            message = t('failed_to_create_online_meeting_room')
            redirect_to params[:redir_url], :error => message
          else
            load_data
            render :action => "new"
          end
        }
        format.json { render :json => @room.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def update_recipient_list
    recipients_array = params[:recipients].split(",").collect{ |s| s.to_i }
    @recipients = User.find(recipients_array)
    render :update do |page|
      page.replace_html 'recipient-list', :partial => 'recipient_list'
    end
  end

  def list_employees
    unless params[:id] == ''
      @employees = Employee.find(:all, :conditions=>{:employee_department_id => params[:id]},:order=>"id DESC")
    else
      @employees = []
    end
    render(:update) do |page|
      page.replace_html 'select_employees', :partial=> 'list_employees'
    end
  end

  def select_employee_department
    @user = current_user
    @departments = EmployeeDepartment.find(:all, :conditions=>"status = true")
    render :partial=>"select_employee_department"
  end

  def select_users
    @user = current_user
    users = User.find(:all, :conditions=>"student = false")
    @to_users = users.map { |s| s.id unless s.nil? }
    render :partial=>"to_users", :object => @to_users
  end

  def select_student_course
    @user = current_user
    @batches = Batch.active
    render :partial=> "select_student_course"
  end

  def to_employees
    if params[:dept_id] == ""
      render :update do |page|
        page.replace_html "to_users", :text => ""
      end
      return
    end
    department = EmployeeDepartment.find(params[:dept_id])
    employees = department.employees(:include=>:user)
    @to_users = employees.map { |s| s.user }.compact||[]
    render :update do |page|
      page.replace_html 'to_users', :partial => 'to_users', :object => @to_users
    end
  end

  def to_students
    if params[:batch_id] == ""
      render :update do |page|
        page.replace_html "to_users2", :text => ""
      end
      return
    end
    batch = Batch.find(params[:batch_id])
    students = batch.students(:include=>:user)
    @to_users = students.map { |s| s.user }.compact||[]
    render :update do |page|
      page.replace_html 'to_users2', :partial => 'to_users', :object => @to_users
    end
  end

  def load_data
    @servers = OnlineMeetingServer.all
    @departments = EmployeeDepartment.active(:order=>"name asc")
    @batches = Batch.active
  end

  def update
    @room = OnlineMeetingRoom.find_by_id(params[:id])
    @room.user_id = current_user.id
    respond_to  do |format|
      @room.member_ids = params[:recipients].split(",").collect{ |s| s.to_i }
      @room.save
      if @room.update_attributes(params[:online_meeting_room])
        message = t('online_meeting_room_successfully_added')
        format.html {
          params[:redir_url] ||= online_meeting_room_path(:id=>@room)
          redirect_to params[:redir_url], :notice => message
        }
        format.json { render :json => { :message => message } }
      else
        format.html {
          unless params[:redir_url].blank?
            message = t('failed_to_update_online_meeting_room')
            redirect_to params[:redir_url], :error => message
          else
            render :action => "edit"
          end
        }
        format.json { render :json => @room.errors.full_messages, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @room = OnlineMeetingRoom.find_by_id(params[:id])

    # TODO Destroy the room record even if end_meeting failed?

    error = false
    begin
      @room.fetch_is_running?
      @room.send_end if @room.is_running?
    rescue BigBlueButton::BigBlueButtonException => e
      error = true
      message = e.to_s
      # TODO Better error message: "Room destroyed in DB, but not in BBB..."
    end

    @room.destroy

    respond_to do |format|
      format.html {
        flash[:error] = message if error
        params[:redir_url] ||= online_meeting_rooms_url
        redirect_to params[:redir_url]
      }
      if error
        format.json { render :json => { :message => message }, :status => :error }
      else
        message = t('online_meeting_room_successfully_destroyed')
        format.json { render :json => { :message => message } }
      end
    end
    flash[:notice] = "#{t('online_meeting_room_successfully_destroyed')}"
  end

  # Used by logged users to join public rooms.
  def join
    @room = OnlineMeetingRoom.find_by_id(params[:id])
    role = @room.user_role(current_user)
    unless role == :denied
      join_internal(current_user.full_name, role, :join)
    else
      flash[:notice] = "#{t('access_denied')}"
      redirect_to :index and return
    end
  end


  def running
    @room = OnlineMeetingRoom.find_by_id(params[:id])

    begin
      @room.fetch_is_running?
    rescue BigBlueButton::BigBlueButtonException => e
      flash[:error] = e.to_s
      render :json => { :running => "false", :error => "#{e.to_s}" }
    else
      render :json => { :running => "#{@room.is_running?}" }
    end

  end

  def end_meeting
    @room = OnlineMeetingRoom.find_by_id(params[:id])

    error = false
    begin
      @room.fetch_is_running?
      if @room.is_running?
        @room.send_end
        @room.make_inactive
        message = t('online_meeting_successfully_ended')
      else
        error = true
        message = t('end_failure_online_meeting_not_running')
      end
    rescue BigBlueButton::BigBlueButtonException => e
      error = true
      message = e.to_s
    end

    if error
      respond_to do |format|
        format.html {
          flash[:error] = message
          redirect_to request.referer
        }
        format.json { render :json => message, :status => :error }
      end
    else
      respond_to do |format|
        format.html {
          redirect_to(online_meeting_room_path(@room), :notice => message)
        }
        format.json { render :json => message }
      end
    end
    flash[:notice] = "#{t('online_meeting_successfully_ended')}"
  end

  def view_meetings_by_date
    @date = (params[:meetings][:search_date]).to_date
    
    if current_user.admin?
      @rooms = OnlineMeetingRoom.all(:conditions=>"(scheduled_on >= '#{@date.strftime("%Y-%m-%d 00:00:00")}' and scheduled_on <= '#{@date.strftime("%Y-%m-%d 23:59:59")}' )",:order=>"id DESC")
    else
      @rooms = OnlineMeetingRoom.rooms_for_user(current_user,@date)
    end

    render :update do|page|
      page.replace_html "activities", :partial=>"date_show"
      page.replace_html "event-table", :partial=>"meetings"
      flash[:notices]= "#{t('online_meeting_for_selected_date')}"
    end
  end


  protected

  def join_internal(username, role, wait_action)


    @room.fetch_is_running?

    # if the current user is a moderator, create the room (if needed)
    # and join it
    if role == :moderator

      add_domain_to_logout_url(@room, request.protocol, request.host)

      @room.send_create unless @room.is_running?
      join_url = @room.join_url(username, role)
      redirect_to(join_url)

      # normal user only joins if the conference is running
      # if it's not, wait for a moderator to create the conference
    else
      if @room.is_running?
        join_url = @room.join_url(username, role)
        redirect_to(join_url)
      else
        flash[:error] = t('authentication_failure_online_meeting_not_running')
        render :action => wait_action
      end
    end


  end

  def add_domain_to_logout_url(room, protocol, host)
    unless @room.logout_url.nil? or @room.logout_url =~ /^[a-z]+:\/\//  # matches the protocol
      unless @room.logout_url =~ /^[a-z0-9]+([\-\.]{ 1}[a-z0-9]+)*/     # matches the host domain
        @room.logout_url = host + @room.logout_url
      end
      @room.logout_url = protocol + @room.logout_url
    end
  end




  helper_method :bigbluebutton_user, :bigbluebutton_role

  def bigbluebutton_user
    @current_user
  end

  def bigbluebutton_role(room)
    if room.private or bigbluebutton_user.nil?
      :password # ask for a password
    else
      :moderator
    end
  end



end
