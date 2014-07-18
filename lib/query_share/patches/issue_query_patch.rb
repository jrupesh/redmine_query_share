module QueryShare
  module Patches
    module IssueQueryPatch
      
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          alias_method_chain :visible?, :share
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
      end
    end
  end
end

IssueQuery.send(:include, QueryShare::Patches::IssueQueryPatch)