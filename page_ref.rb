#
# page_ref.rb - Tags to refer the page by ID which be assigned to.
#
# USAGE:
#
# 1. Add page_id property to assign ID in YAML Header of target page.
#
#     page_id: some-page-id
#
# 2. Add tags in other pages or posts, those will be expanded...
#
#     {% page_url some-page-id %}  - to the page's URL.
#     {% page_link some-page-id %} - to the page's link and title.

# page_ref.rb - ページにIDを割り当てて、そのIDで参照するタグ
#
# USAGE:
#
# 1. YAML Header に page_id というタグを追加する
#
#     page_id: some-page-id
#
# 2. 各ページに以下のタグを書くとURLやリンクに展開されます
#
#     {% page_url some-page-id %}  - ページのURLに展開
#     {% page_link some-page-id %} - ページのタイトル&リンクに展開

module PageRef

  class PageIDCollector < Jekyll::Generator

    def PageIDCollector.page_file(page)
      page.instance_eval {
        File.join(@dir, @name)
      }
    end

    def initialize(config)
    end

    def generate(site)
      table = {}

      add = lambda { |p|
        if p.data.has_key?('page_id')
          page_id = p.data['page_id'].strip
          if table.has_key?(page_id)
            first = PageIDCollector.page_file(table[page_id])
            second = PageIDCollector.page_file(p)
            raise "Duplicated page_id \"#{page_id}\" at \"#{first}\" and \"#{second}\""
          end
          table[page_id] = p
        end
      }

      site.pages.each { |p| add.call(p) }
      site.posts.each { |p| add.call(p) }

      site.config['_page_id_table'] = table
    end
  end

  class PageRefTag < Liquid::Tag
    def initialize(tag_name, page_id, tokens)
      super
      @page_id = page_id.strip
    end

    def render(context)
      table = context.registers[:site].config['_page_id_table']
      if table.has_key?(@page_id)
        return render_page(context, table[@page_id].to_liquid)
      else
        errmsg = "ERROR: page_url: \"#{@page_id}\" could not be found"
        puts errmsg
        return errmsg
      end
    end
  end

  class PageURLTag < PageRefTag
    def render_page(context, page)
      page['url']
    end
  end

  class PageLinkTag < PageRefTag
    def render_page(context, page)
      url = page['url']
      title = page['title']
      return "<a href=\"#{url}\">#{title}</a>"
    end
  end
end

Liquid::Template.register_tag('page_url', PageRef::PageURLTag)
Liquid::Template.register_tag('page_link', PageRef::PageLinkTag)

# vim:set ts=8 sts=2 sw=2 tw=0 et:
