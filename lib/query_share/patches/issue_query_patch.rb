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

          scope :esi_visible_queries, lambda {|*args|
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
                  " INNER JOIN #{table_name_prefix}queries_users#{table_name_suffix} qu on qu.query_id = q.id" +
                  " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = qr.role_id" +
                  " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" +
                  " WHERE q.project_id IS NULL OR q.project_id = m.project_id))" +
                " OR #{table_name}.user_id = ?",
                IssueQuery::VISIBILITY_PUBLIC, IssueQuery::VISIBILITY_ROLES, IssueQuery::VISIBILITY_GROUP, user.id, user.id)
            elsif user.logged?
              scope.where("#{table_name}.visibility = ? OR #{table_name}.user_id = ?", IssueQuery::VISIBILITY_PUBLIC, user.id)
            else
              scope.where("#{table_name}.visibility = ?", IssueQuery::VISIBILITY_PUBLIC)
            end
          }
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def visible_with_share?(user=User.current)
          return true if visible_without_share?(user) == true
          case visibility
          when IssueQuery::VISIBILITY_GROUP
            user.queries.include?(self)
          else
            false
          end
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
