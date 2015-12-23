module QueriesHelper
  unloadable

  def collect_name_id_label_value_hash(project)
    project.nil? ?
      Principal.active.visible.sorted.map{ |s| { label: s.name, value: s.login.present? ? s.login : s.lastname } } :
      Principal.member_of([project]).sorted.map{ |s| { label: s.name, value: s.login.present? ? s.login : s.lastname } } +
               Group.includes(:custom_values).where('custom_values.customized_type' => 'Principal',
                      'custom_values.custom_field_id' => Setting.plugin_redmine_query_share["group_cf"] ).map{
                        |s| { label: s.name, value: s.lastname } }
  end
end
