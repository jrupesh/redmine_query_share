module IssuesHelper
  unloadable

  def query_links_with_share(title, queries)
    return '' if queries.empty?
    return query_links_without_share unless Setting.plugin_redmine_query_share['query_share_enable'] == "1"
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

  def sidebar_queries_with_share
    return sidebar_queries_without_share unless Setting.plugin_redmine_query_share['query_share_enable'] == "1"
    unless @sidebar_queries
      @sidebar_queries = IssueQuery.visible.joins(:user).
        order("#{Query.table_name}.name ASC").
        # Project specific queries and global queries
        where(@project.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", @project.id]).
        to_a
    end
    @sidebar_queries
  end
  alias_method_chain :sidebar_queries, :share
end
