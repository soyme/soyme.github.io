module Jekyll
  class CatsAndTags < Generator
    safe true

    def generate(site)
      site.categories.each do |category|
        cate_value = "#{category[0]}";
        cf = "#{cate_value}_pagenate"
        per_page = site.config[cf]
        build_subpages(site, "category", category, per_page, cate_value)
      end

      site.tags.each do |tag|
        build_subpages(site, "tag", tag, site.config['tag_pagenate'], "tag")
      end
    end

    def build_subpages(site, type, posts, per_page, cf) 
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }     
      paginate(site, type, posts, per_page, cf)
    end

    def paginate(site, type, posts, per_page, cf)
      conf_per_page = site.config['category_paginate']
      pages = Jekyll::CategoryPaginate::Pager.calculate_pages(posts[1], per_page.to_i)
      (1..pages).each do |num_page|
        pager = Jekyll::CategoryPaginate::Pager.new(site, num_page, posts[1], per_page.to_i, pages)
        path = "/#{type}/#{posts[0]}"
        if num_page > 1
          path = path + "/page#{num_page}"
        end
        newpage = GroupSubPage.new(site, site.source, path, type, posts[0], cf)
        newpage.pager = pager
        site.pages << newpage 

      end
    end
  end

  class GroupSubPage < Page
    def initialize(site, base, dir, type, val, cf)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      #filename = "#{type}_index.html"
	  filename = "#{cf}_index.html"
      self.read_yaml(File.join(base, '_layouts'), filename)
      self.data["grouptype"] = type
      self.data[type] = val
    end
  end
end
