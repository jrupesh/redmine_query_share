Rails.configuration.to_prepare do
  require 'query_share/patches/issue_query_patch'
  require 'query_share/patches/query_patch'
  require 'query_share/patches/queries_controller_patch'
  require 'query_share/patches/queries_helper_patch'
end

#ActionDispatch::Callbacks.to_prepare do
ActiveSupport::Reloader.to_prepare do
  require_dependency 'query_share/hooks/view_layout'
end

Redmine::Plugin.register :redmine_query_share do
  name 'Redmine Query share'
  author 'Rupesh J'
  description 'Share your redmine queries among specific user across user roles.'
  version '2.1.0'
  author_url 'mailto:rupeshj@esi-group.com'

  requires_redmine :version_or_higher => '3.4.0'

  settings :default => {  :query_share_enable => false,
                          :user_count         => 20,
                          :group_cf           => 0 },
  	:partial => 'settings/query_share_settings'

  project_module :issue_tracking do
    permission :manage_group_queries, {:queries => [:new, :create, :edit, :update, :destroy]}, :require => :member
  end
end
