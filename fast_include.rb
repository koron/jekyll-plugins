module FastInclude

  class IncludeFileCollector < Jekyll::Generator
    def initialize(config)
    end

    def generate(site)
      includes_dir = File.join(site.source, '_includes')
      if File.symlink?(includes_dir)
        raise "Includes directory '#{includes_dir}' cannot be a symlink"
      end
      choices = []
      Dir.chdir(includes_dir) do
        choices = Dir['**/*'].reject { |x| File.symlink?(x) }
      end
      site.config['_fast_include_choices'] = choices
      site.config['_fast_include_cache'] = {}
    end
  end

  class FastIncludeTag < Liquid::Tag
    def initialize(tag_name, file, tokens)
      super
      @file = file.strip
    end

    def source(cache, path, opts)
      if cache.has_key?(path)
        source = cache[path]
      else
        source = File.read(path, opts)
        cache[path] = source
      end
      return source
    end

    def render(context)
      if @file !~ /^[a-zA-Z0-9_\/\.-]+$/ || @file =~ /\.\// || @file =~ /\/\./
        return "Include file '#{@file}' contains invalid characters or sequences"
      end

      site = context.registers[:site]
      includes_dir = File.join(site.source, '_includes')
      config = site.config
      choices = config['_fast_include_choices']
      cache = config['_fast_include_cache']

      if choices.include?(@file)
        path = File.join(includes_dir, @file)
        source = self.source(cache, path, site.file_read_opts)
        partial = Liquid::Template.parse(source)
        context.stack do
          partial.render(context)
        end
      else
        "Included file '#{@file}' not found in _includes directory"
      end
    end
  end
end

#Liquid::Template.register_tag('include', FastInclude::FastIncludeTag)

# vim:set ts=8 sts=2 sw=2 tw=0 et:
