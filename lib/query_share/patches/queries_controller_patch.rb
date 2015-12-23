module QueryShare
  module Patches
    module QueriesControllerPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          alias_method_chain :update_query_from_params, :share
        end
      end

      module ClassMethods
      end

      module InstanceMethods
        def update_query_from_params_with_share
          @query.principal_ids = params[:query] && params[:query][:principal_ids]
          @query.principals_logins = params[:query] && params[:query][:principals_logins]
          update_query_from_params_without_share
        end
      end
    end
  end
end

unless QueriesController.included_modules.include? QueryShare::Patches::QueriesControllerPatch
  QueriesController.send(:include, QueryShare::Patches::QueriesControllerPatch)
end
