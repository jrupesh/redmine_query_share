module IssuesHelper
  def sidebar_queries_with_share
    @sidebar_queries = sidebar_queries_without_share
    @sidebar_queries + User.current.queries
  end
  alias_method_chain :sidebar_queries, :share
end
