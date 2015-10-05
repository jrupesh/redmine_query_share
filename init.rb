Rails.configuration.to_prepare do
  require 'query_share/patches/issue_query_patch'
  require 'query_share/patches/issues_helper_patch'
  require 'query_share/patches/queries_controller_patch'
  require 'query_share/patches/query_patch'
  require 'query_share/patches/user_patch'
end

Redmine::Plugin.register :redmine_query_share do
  name 'Redmine Query share'
  author 'Rupesh J'
  description 'Share your redmine queries among specific user across user roles.'
  version '1.0.2'
  author_url 'mailto:rupeshj@esi-group.com'

  settings :default => {  :query_share_enable => false },
  	:partial => 'settings/query_share_settings'
end
