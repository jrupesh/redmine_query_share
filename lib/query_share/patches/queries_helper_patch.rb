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

  def query_links_with_share(title, queries)
    return '' if queries.empty?
    return query_links_without_share(title, queries) unless Setting.plugin_redmine_query_share['query_share_enable'] == "1"
    # links to #index on issues/show
    url_params = controller_name == 'issues' ? {:controller => 'issues', :action => 'index', :project_id => @project} : params

    content_tag('h3', title) + "\n" +
        content_tag('ul',
                    queries.collect {|query|
                      css = 'query'
                      css << ' selected' if query == @query
                      css << " visible#{query.visibility}"
                      content_tag('li', link_to(query.name, url_params.merge(:query_id => query), :class => css,
                                                :title => l(:field_author) + ": #{query.user.name}"))
                    }.join("\n").html_safe,
                    :class => 'queries'
        ) + "\n"
  end
  alias_method_chain :query_links, :share

  def sidebar_queries_with_share(klass, project)
    return sidebar_queries_without_share(klass, project) unless Setting.plugin_redmine_query_share['query_share_enable'] == "1"
    unless @sidebar_queries
      @sidebar_queries = klass.visible.global_or_on_project(@project).sorted.joins(:user).to_a
    end
    @sidebar_queries
  end
  alias_method_chain :sidebar_queries, :share
end
