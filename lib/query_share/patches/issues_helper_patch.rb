require_dependency 'issues_helper'

module QueryShare
  module Patches
    module IssuesHelperPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :sidebar_queries, :share
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def sidebar_queries_with_share
          unless @sidebar_queries
            @sidebar_queries = sidebar_queries_without_share
            @sidebar_queries += User.current.queries if Setting.plugin_redmine_query_share['query_share_enable'] == "1"
            @sidebar_queries.uniq!
          end
          @sidebar_queries
        end
      end
    end
  end
end

unless IssuesHelper.included_modules.include? QueryShare::Patches::IssuesHelperPatch
  IssuesHelper.send(:include, QueryShare::Patches::IssuesHelperPatch)
end
