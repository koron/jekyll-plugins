module ParentPages

  class ParentsCollector < Jekyll::Generator

    def cache_page_url(site)
      site.pages.each { |page|
        if not page.data.has_key?('cached_url')
          page.data['cached_url'] = page.to_liquid['url']
        end
      }
    end

    def generate(site)
      cache_page_url(site)
      site.pages.each { |page|
        page.data['parents'] = get_parents(site, page)
      }
    end

    def get_parents(site, target)
      parents = []
      url = target.data['cached_url']
      site.pages.each { |page|
        page_url = page.data['cached_url']
        if page != target and url.start_with?(page_url) and page_url != '/'
          parents.unshift(page)
        end
      }
      return parents
    end

  end

end
