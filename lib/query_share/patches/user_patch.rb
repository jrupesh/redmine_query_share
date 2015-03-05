require_dependency 'user'

module QueryShare
  module Patches
    module UserPatch

      def self.included(base) # :nodoc:
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          has_and_belongs_to_many :queries, :join_table => "#{table_name_prefix}queries_users#{table_name_suffix}",
            :class_name => 'Query', :foreign_key => 'user_id'
        end
      end

      module ClassMethods
      end

      module InstanceMethods
      end
    end
  end
end


unless User.included_modules.include? QueryShare::Patches::UserPatch
  User.send(:include, QueryShare::Patches::UserPatch)
end