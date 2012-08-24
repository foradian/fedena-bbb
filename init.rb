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
