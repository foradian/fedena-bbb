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
class OnlineMeetingRoom < ActiveRecord::Base
  belongs_to :user
  belongs_to :server,:class_name=>"OnlineMeetingServer"
  named_scope :active,:conditions=>"is_active=1"

  has_many :online_meeting_members
  has_many :members,:class_name=>"User",:through=>:online_meeting_members
 
  validates_presence_of :server_id
  validates_presence_of :meetingid
  validates_uniqueness_of :meetingid,:scope=>:is_active
  validates_length_of :meetingid,:maximum => 100

  validates_presence_of :name
  validates_uniqueness_of  :name,:scope=>:is_active
  validates_length_of  :name, :maximum => 150

  validates_length_of :welcome_msg,:maximum => 250
  validates_inclusion_of :private,:in => [true, false]
  validates_inclusion_of :randomize_meetingid,:in => [true, false]

  validates_presence_of :voice_bridge
  validates_uniqueness_of :voice_bridge,:scope=>:is_active

  validates_presence_of :param
  validates_uniqueness_of :param,:scope=>:is_active
  validates_length_of :param ,:minimum=>3
  validates_format_of :param,:with => /^[a-zA-Z\d_]+[a-zA-Z\d_-]*[a-zA-Z\d_]+$/

  # Passwords are 16 character strings
  # See http://groups.google.com/group/OnlineMeeting-dev/browse_thread/thread/9be5aae1648bcab?pli=1

  validates_length_of :attendee_password,:maximum => 16
  validates_length_of :moderator_password,:maximum => 16

  validates_presence_of :attendee_password,:if => :private?
  validates_presence_of :moderator_password,:if => :private?


  attr_accessible :name, :meetingid, :attendee_password, :moderator_password,
    :welcome_msg, :owner, :server, :private, :logout_url, :dial_number,
    :voice_bridge, :max_participants, :owner_id, :owner_type, :randomize_meetingid,
    :external, :param,:host_url,:scheduled_on,:is_active,:server_id
  
  # Note: these params need to be fetched from the server before being accessed
  attr_accessor :running, :participant_count, :moderator_count, :attendees,
    :has_been_forcibly_ended, :start_time, :end_time,:host_url

  after_initialize :init
  before_validation :set_defaults

  # Convenience method to access the attribute <tt>running</tt>
  def is_running?
    @running
  end

  def self.rooms_for_user(user,date)
    self.find(:all,:joins=>:online_meeting_members,\
        :conditions=>"(`online_meeting_members`.member_id = #{user.id} OR `online_meeting_rooms`.user_id=#{user.id}) and `online_meeting_rooms`.is_active = 1" + \
        " AND (scheduled_on >= '#{date.strftime("%Y-%m-%d 00:00:00")}' and scheduled_on <= '#{date.strftime("%Y-%m-%d 23:59:59")}')" )
  end

  def make_inactive
    self.update_attributes(:is_active=>false)
  end
  

  # Fetches info from BBB about this room.
  # The response is parsed and stored in the model. You can access it using attributes such as:
  #
  #   room.participant_count
  #   room.attendees[0].full_name
  #
  # The attributes changed are:
  # * <tt>participant_count</tt>
  # * <tt>moderator_count</tt>
  # * <tt>running</tt>
  # * <tt>has_been_forcibly_ended</tt>
  # * <tt>start_time</tt>
  # * <tt>end_time</tt>
  # * <tt>attendees</tt> (array of <tt>OnlineMeetingAttendee</tt>)
  #
  # Triggers API call: <tt>get_meeting_info</tt>.
  def fetch_meeting_info
    response = self.server.api.get_meeting_info(self.meetingid, self.moderator_password)

    @participant_count = response[:participantCount]
    @moderator_count = response[:moderatorCount]
    @running = response[:running]
    @has_been_forcibly_ended = response[:hasBeenForciblyEnded]
    @start_time = response[:startTime]
    @end_time = response[:endTime]
    @attendees = []
    response[:attendees].each do |att|
      attendee = OnlineMeetingAttendee.new
      attendee.from_hash(att)
      @attendees << attendee
    end

    response
  end

  # Fetches the BBB server to see if the meeting is running. Sets <tt>running</tt>
  #
  # Triggers API call: <tt>is_meeting_running</tt>.
  def fetch_is_running?
    @running = self.server.api.is_meeting_running?(self.meetingid)
  end

  # Sends a call to the BBB server to end the meeting.
  #
  # Triggers API call: <tt>end_meeting</tt>.
  def send_end
    self.server.api.end_meeting(self.meetingid, self.moderator_password)
  end

  # Sends a call to the BBB server to create the meeting.
  #
  # With the response, updates the following attributes:
  # * <tt>attendee_password</tt>
  # * <tt>moderator_password</tt>
  #
  # Triggers API call: <tt>create_meeting</tt>.
  def send_create

    unless self.randomize_meetingid
      response = do_create_meeting

      # create a new random meetingid everytime create fails with "duplicateWarning"
    else
      self.meetingid = random_meetingid

      count = 0
      try_again = true
      while try_again and count < 10
        response = do_create_meeting

        count += 1
        try_again = false
        unless response.nil?
          if response[:returncode] && response[:messageKey] == "duplicateWarning"
            self.meetingid = random_meetingid
            try_again = true
          end
        end

      end
    end

    unless response.nil?
      self.attendee_password = response[:attendeePW]
      self.moderator_password = response[:moderatorPW]
      self.save
    end

    response
  end

  # Returns the URL to join this room.
  # username:: Name of the user
  # role:: Role of the user in this room. Can be <tt>[:moderator, :attendee]</tt>
  #
  # Uses the API but does not require a request to the server.
  def join_url(username, role)
    if role == :moderator
      self.server.api.join_meeting_url(self.meetingid, username, self.moderator_password)
    else
      self.server.api.join_meeting_url(self.meetingid, username, self.attendee_password)
    end
  end


  def user_role(current_user)
    role = nil
    if self.user
      if current_user.admin? or current_user.id==self.user.id
          role = :moderator
      else
        if self.members.collect(&:id).include?(current_user.id)
          role = :attendee
        else
          role = :denied
        end
      end
    end
    role
  end

  # Compare the instance variables of two models to define if they are equal
  # Returns a hash with the variables with different values or an empty hash
  # if they are have all equal values.
  # From: http://alicebobandmallory.com/articles/2009/11/02/comparing-instance-variables-in-ruby
  def instance_variables_compare(o)
    vars = [ :@running, :@participant_count, :@moderator_count, :@attendees,
      :@has_been_forcibly_ended, :@start_time, :@end_time ]
    Hash[*vars.map { |v|
        self.instance_variable_get(v)!=o.instance_variable_get(v) ?
          [v,o.instance_variable_get(v)] : []}.flatten]
  end

  # A more complete equal? method, comparing also the attibutes and
  # the instance variables
  def attr_equal?(o)
    self == o and
      self.instance_variables_compare(o).empty? and
      self.attributes == o.attributes
  end


  protected

  def init
    self[:meetingid] ||= random_meetingid
    self[:voice_bridge] ||= random_voice_bridge

    # fetched attributes
    @participant_count = 0
    @moderator_count = 0
    @running = false
    @has_been_forcibly_ended = false
    @start_time = nil
    @end_time = nil
    @attendees = []
  end

  def random_meetingid
    #ActiveSupport::SecureRandom.hex(16)
    # TODO temporarily using the name to get a friendlier meetingid
    if self[:name].blank?
      ActiveSupport::SecureRandom.hex(8)
    else
      self[:name] + '-' + ActiveSupport::SecureRandom.random_number(9999).to_s
    end
  end

  def random_voice_bridge
    value = (70000 + ActiveSupport::SecureRandom.random_number(9999)).to_s
    count = 0
    while not OnlineMeetingRoom.find_by_voice_bridge(value).nil? and count < 10
      count += 1
      value = (70000 + ActiveSupport::SecureRandom.random_number(9999)).to_s
    end
    value
  end

  def do_create_meeting
    self.server.api.create_meeting(self.name, self.meetingid, self.moderator_password,
      self.attendee_password, self.welcome_msg, self.dial_number,
      self.logout_url, self.max_participants, self.voice_bridge)
  end

  # if :param wasn't set, sets it as :name downcase and parameterized
  def set_defaults
    self.param = self.name.parameterize.downcase unless self.name.nil?
    self.welcome_msg = "#{t('welcome_to')} #{self.name}"
    self.logout_url = "#{self.host_url}"
    if self.new_record?
      self.is_active = true
      self.randomize_meetingid = true
      self.meetingid = random_meetingid
      self.attendee_password = "#{self.user_id}-#{self.meetingid[0..10]}"
      self.moderator_password = "M#{self.user_id}-#{self.meetingid[0..10]}"
      self.max_participants = 30
      self.private = true
      self.voice_bridge = self.meetingid
    end
  end
end
