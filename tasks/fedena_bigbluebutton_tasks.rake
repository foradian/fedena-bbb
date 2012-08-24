namespace :fedena_bigbluebutton do
  desc "Install BigblueButton module for Fedena"
  task :install do
    system "rsync --exclude=.svn -ruv vendor/plugins/fedena_bigbluebutton/public ."
  end
end
