Rails.configuration.to_prepare do
  require 'query_share/patches/issue_query_patch'
  require 'query_share/patches/query_patch'
  require 'query_share/patches/queries_controller_patch' if Redmine::VERSION::MAJOR >= 3
  require 'query_share/patches/queries_helper_patch'
end


Redmine::Plugin.register :redmine_query_share do
  name 'Redmine Query share'
  author 'Rupesh J'
  description 'Share your redmine queries among specific user across user roles.'
  version '2.0.2'
  author_url 'mailto:rupeshj@esi-group.com'

  settings :default => {  :query_share_enable => false,
                          :user_count         => 20,
                          :group_cf           => 0 },
  	:partial => 'settings/query_share_settings'

  project_module :issue_tracking do
    permission :manage_group_queries, {:queries => [:new, :create, :edit, :update, :destroy]}, :require => :member
  end
end
