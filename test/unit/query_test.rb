require File.expand_path('../../test_helper', __FILE__)

class QueryTest < ActiveSupport::TestCase
  include Redmine::I18n

  fixtures :projects, :enabled_modules, :users, :members,
           :member_roles, :roles, :trackers, :issue_statuses,
           :issue_categories, :enumerations, :issues,
           :watchers, :custom_fields, :custom_values, :versions,
           :queries,
           :projects_trackers,
           :custom_fields_trackers,
           :workflows, :email_addresses

  def setup
    User.current = nil
    Setting.plugin_redmine_query_share['query_share_enable'] = "1"
  end

  def test_query_with_group_visibility_should_validate_users
    set_language_if_valid 'en'
    query = IssueQuery.new(:name => 'Query', :visibility => IssueQuery::VISIBILITY_GROUP)
    assert !query.save
    assert_include "Users cannot be blank", query.errors.full_messages
    query.principal_ids = [1, 2]
    assert query.save
  end

  def test_changing_groups_visibility_should_clear_users
    query = IssueQuery.create!(:name => 'Query', :visibility => IssueQuery::VISIBILITY_GROUP, :principal_ids => [1, 2])
    assert_equal 2, query.users.count

    query.visibility = IssueQuery::VISIBILITY_PUBLIC
    query.save!
    assert_equal 0, query.users.count
  end

  def test_query_with_group_visibility_should_be_visible_to_user_with_group
    q = IssueQuery.create!(:name => 'Query', :visibility => IssueQuery::VISIBILITY_GROUP, :principal_ids => [1,2])

    assert !q.visible?(User.anonymous)
    assert_nil IssueQuery.visible(User.anonymous).find_by_id(q.id)

    assert !q.visible?(User.find(7))
    assert_nil IssueQuery.visible(User.find(7)).find_by_id(q.id)

    assert q.visible?(User.find(2))
    # assert IssueQuery.visible(User.find(2)).find_by_id(q.id)

    assert q.visible?(User.find(1))
    # assert IssueQuery.visible(User.find(1)).find_by_id(q.id)
  end
end