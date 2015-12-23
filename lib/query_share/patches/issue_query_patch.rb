require_dependency 'issue_query'

module QueryShare
  module Patches
    module IssueQueryPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :visible?, :share

          scope :esi_visible, lambda {|*args|
            user = args.shift || User.current
            base = Project.allowed_to_condition(user, :view_issues, *args)
            scope = joins("LEFT OUTER JOIN #{Project.table_name} ON #{table_name}.project_id = #{Project.table_name}.id").
              where("#{table_name}.project_id IS NULL OR (#{base})")

            if user.admin?
              scope.where("#{table_name}.visibility <> ? OR #{table_name}.user_id = ?", IssueQuery::VISIBILITY_PRIVATE, user.id)
            elsif user.memberships.any?
              scope.where("#{table_name}.visibility = ?" +
              " OR (#{table_name}.visibility = ? OR #{table_name}.visibility = ? AND #{table_name}.id IN (" +
              "SELECT DISTINCT q.id FROM #{table_name} q" +
              " INNER JOIN #{table_name_prefix}queries_roles#{table_name_suffix} qr on qr.query_id = q.id" +
              " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = qr.role_id" +
              " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" +
              " WHERE q.project_id IS NULL OR q.project_id = m.project_id" +
              " UNION " +
              "SELECT DISTINCT q.id FROM #{table_name} q" +
              " LEFT OUTER JOIN #{table_name_prefix}queries_users#{table_name_suffix} qu on qu.query_id = q.id" +
              " LEFT OUTER JOIN #{table_name_prefix}groups_users#{table_name_suffix} g on g.group_id = qu.user_id AND g.user_id = ?" +
              " LEFT OUTER JOIN #{Member.table_name} m ON m.user_id = g.user_id OR m.user_id = ?" +
              " WHERE q.project_id IS NULL OR q.project_id = m.project_id))" +
              " OR #{table_name}.user_id = ?", IssueQuery::VISIBILITY_PUBLIC, IssueQuery::VISIBILITY_ROLES, IssueQuery::VISIBILITY_GROUP,
              user.id, user.id, user.id, user.id)
            elsif user.logged?
              scope.where("#{table_name}.visibility = ? OR #{table_name}.user_id = ?", IssueQuery::VISIBILITY_PUBLIC, user.id)
            else
              scope.where("#{table_name}.visibility = ?", IssueQuery::VISIBILITY_PUBLIC)
            end
          }

          class << self
            alias_method :visible,  :esi_visible
          end
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def principals_logins= (str_val)
          return if str_val.nil?
          update_principals = str_val.split(",")
          update_principals = update_principals.map{ |x| x.strip }
          update_principals.delete_if {|x| x.blank? }

          logger.debug("Redmine QueryShare : users to update #{update_principals}")
          cur_principals = self.principals.map{ |u| u.login.present? ? u.login : u.lastname }
          return if cur_principals.sort == update_principals.sort

          self.principals.clear
          self.principals = Principal.where("users.login in (?) OR users.lastname in (?)", update_principals, update_principals)
          logger.debug("Redmine QueryShare : users updated #{self.principals.to_a}")
        end

        def visible_with_share?(user=User.current)
          return true if visible_without_share?(user) == true
          case visibility
          when IssueQuery::VISIBILITY_GROUP
            IssueQuery.visible.include?(self)
          else
            false
          end
        end

        def editable_by?(user)
          return false unless user
          # Admin can edit them all and regular users can edit their private queries
          return true if user.admin? || (is_private? && self.user_id == user.id) || (is_shared_with_group? && self.user_id == user.id)

          # Members can not edit Group queries that are for all project (only admin is allowed to)
          return true if is_shared_with_group? && !@is_for_all && user.allowed_to?(:manage_group_queries, project)

          # Members can not edit public queries that are for all project (only admin is allowed to)
          is_public? && !@is_for_all && user.allowed_to?(:manage_public_queries, project)
        end

        def is_shared_with_group?
          visibility == IssueQuery::VISIBILITY_GROUP
        end
      end
    end
  end
end

unless IssueQuery.included_modules.include? QueryShare::Patches::IssueQueryPatch
  IssueQuery.send(:include, QueryShare::Patches::IssueQueryPatch)
end
