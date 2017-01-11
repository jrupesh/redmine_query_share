module QueryShare
  module Patches
    class ViewLayout < Redmine::Hook::ViewListener
      def view_layouts_base_html_head(context = { })
        return '' unless User.current.admin?
        o = ""
        o += "<style>
.query.visible1 { color: #fdbf3b;}
.query.visible2 { color: #f66;}
.query.visible3 { color: #00c600;}
</style>"
        return o.html_safe
      end
    end
  end
end