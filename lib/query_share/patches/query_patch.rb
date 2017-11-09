module QueryShare
  module Patches
    module QueryPatch

      def self.included(base)
        base.const_set('VISIBILITY_GROUP', 3)
        base.send(:include, InstanceMethods)

        base.class_eval do
          unloadable
          has_and_belongs_to_many :query_principals, :join_table   => "#{table_name_prefix}queries_users#{table_name_suffix}",
            :class_name => 'Principal', :foreign_key => 'query_id', :association_foreign_key => 'user_id'

          query_inclusion_validator = base._validators[:visibility].find{ |validator| validator.is_a? ActiveModel::Validations::InclusionValidator }
          base._validators[:visibility].delete(query_inclusion_validator)
          filter = base._validate_callbacks.find{ |c| c.raw_filter == query_inclusion_validator }.filter
          skip_callback :validate, filter

          validates :visibility, :inclusion => { :in => [base::VISIBILITY_PUBLIC, base::VISIBILITY_ROLES,
                                                 base::VISIBILITY_PRIVATE, base::VISIBILITY_GROUP] }

          validate do |query|
            errors.add(:base, l(:label_user_plural) + ' ' + l('activerecord.errors.messages.blank')) if query.visibility == base::VISIBILITY_GROUP && query_principals.blank?
          end

          after_save do |query|
            if query.visibility_changed? && query.visibility != base::VISIBILITY_GROUP
              query.query_principals.clear
            end
          end
        end
      end

      module InstanceMethods
        def is_shared_with_group?
          visibility == Query::VISIBILITY_GROUP
        end

        def add_principals(user_groups=[])
          self.query_principals += user_groups
          self.query_principals.uniq
        end
      end
    end
  end
end

unless Query.included_modules.include? QueryShare::Patches::QueryPatch
  Query.send(:include, QueryShare::Patches::QueryPatch)
end