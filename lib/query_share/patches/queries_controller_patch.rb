module QueryShare
  module Patches
    module QueriesControllerPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          #alias_method_chain :update_query_from_params, :share
	  alias_method :update_query_from_params_without_share, :update_query_from_params
	  alias_method :update_query_from_params, :update_query_from_params_with_share
        end
      end

      module ClassMethods
      end

      module InstanceMethods
	#def upate_query_from_params_without_share
	#  upate_query_from_params
	#end

        def update_query_from_params_with_share
          update_query_from_params_without_share
          if @query.instance_of? IssueQuery
            share_visibility = params[:query] && params[:query][:visibility]

            if (User.current.allowed_to?(:manage_group_queries, @query.project) || User.current.admin?) &&
             share_visibility.to_i == IssueQuery::VISIBILITY_GROUP
              @query.query_principal_ids = params[:query] && params[:query][:principal_ids]
              @query.principals_logins = params[:query] && params[:query][:principals_logins]
              @query.visibility = share_visibility
            elsif @query.visibility.to_i == IssueQuery::VISIBILITY_GROUP
              @query.visibility = IssueQuery::VISIBILITY_PRIVATE
            end
          end
          @query
        end
      end
    end
  end
end

unless QueriesController.included_modules.include? QueryShare::Patches::QueriesControllerPatch
  QueriesController.send(:include, QueryShare::Patches::QueriesControllerPatch)
end
