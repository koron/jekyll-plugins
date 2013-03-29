module BGGradient

  class Tag < Liquid::Tag 

    def initialize(tag_name, text, tokens)
      super
      @color1, @color2 = text.split(" ")
    end

    def render(context)
      out = []

      out.push "background-color: #{@color2};"
      out.push "background: linear-gradient(#{@color1}, #{@color2});"
      out.push "background: -webkit-gradient(linear, 0 0, 0 100%, from(#{@color1}), to(#{@color2}));"
      out.push "background: -moz-linear-gradient(#{@color1}, #{@color2});"
      out.push "background: -o-linear-gradient(#{@color1}, #{@color2});"
      out.push "filter: progid:DxImageTransform.Microsoft.Gradient(Enabled=1,GradientType=0,StartColorStr=#{@color1.sub(/#/, "#ff")},EndColorStr=#{@color2.sub(/#/, "#ff")});"

      out.join("\n  ")
    end

  end
end

Liquid::Template.register_tag('bg_gradient', BGGradient::Tag)

# vim:set ts=8 sts=2 sw=2 tw=0 et:
