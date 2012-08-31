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
class OnlineMeetingServer < ActiveRecord::Base
  include BigBlueButton
  has_many :rooms,:class_name => 'OnlineMeetingRoom',:foreign_key => 'server_id',:dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_length_of :name,:maximum=>500

  validates_presence_of :url
  validates_uniqueness_of :url
  validates_length_of :url,:maximum=>500
  validates_format_of :url, :with => /http:\/\/.*\/bigbluebutton\/api/

  validates_presence_of :param
  validates_uniqueness_of :param
  validates_length_of :param,:minimum=>3
  validates_format_of :param, :with => /^[a-zA-Z\d_]+[a-zA-Z\d_-]*[a-zA-Z\d_]+$/

  validates_presence_of :salt
  validates_length_of :salt,:maximum=>500

  validates_presence_of :version
  validates_inclusion_of :version, :in => ['0.64', '0.7','0.71','0.8']


  attr_accessible :name, :url, :version, :salt, :param

  # Array of <tt>OnlineMeetingMeeting</tt>
  attr_reader :meetings

  after_initialize :init
  before_validation :set_param

  # Returns the API object (<tt>OnlineMeeting::OnlineMeetingAPI</tt> defined in
  # <tt>OnlineMeeting-api-ruby</tt>) associated with this server.
  def api
    if @api.nil?
      @api = BigBlueButton::BigBlueButtonApi.new(self.url, self.salt,
        self.version.to_s, false)
    end
    @api
  end

  # Fetches the meetings currently created in the server (running or not).
  #
  # Using the response, updates <tt>meetings</tt> with a list of <tt>OnlineMeetingMeeting</tt>
  # objects.
  #
  # Triggers API call: <tt>get_meetings</tt>.
  def fetch_meetings
    response = self.api.get_meetings

    # updates the information in the rooms that are currently in BBB
    @meetings = []
    response[:meetings].each do |attr|
      room = OnlineMeetingRoom.find_by_server_id_and_meetingid(self.id, attr[:meetingID])
      if room.nil?
        room = OnlineMeetingRoom.create(:server => self, :meetingid => attr[:meetingID],
          :name => attr[:meetingID], :attendee_password => attr[:attendeePW],
          :moderator_password => attr[:moderatorPW], :external => true,
          :randomize_meetingid => false)
      else
        room.update_attributes(:attendee_password => attr[:attendeePW],
          :moderator_password => attr[:moderatorPW])
      end
      room.running = attr[:running]

      # TODO What if the update/save above fails?

      @meetings << room
    end
  end

  protected

  def init
    # fetched attributes
    @meetings = []
  end

  # if :param wasn't set, sets it as :name downcase and parameterized
  def set_param
    self.param = self.name.parameterize.downcase unless self.name.nil?
    self.version = "0.8"
  end

end
