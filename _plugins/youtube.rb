class YouTube < Liquid::Tag
  Syntax = /^\s*([^\s]+)\s+(.*)\s*?/

  def initialize(tagName, markup, tokens)
    super

    if markup =~ Syntax then
      @id = $1
      @width = 560
      @height = 315

      if $2.nil? then
          @title = "test"
      else
          @title = $2
      end
    else
      raise "No YouTube ID provided in the \"youtube\" tag"
    end
  end

  def render(context)
    # "<iframe width=\"#{@width}\" height=\"#{@height}\" src=\"http://www.youtube.com/embed/#{@id}\" frameborder=\"0\"allowfullscreen></iframe>"
    "<div class=\"youtube\"><div class=\"movie\"><iframe width=\"#{@width}\" height=\"#{@height}\" src=\"http://www.youtube.com/embed/#{@id}?color=white&theme=light\" frameborder=\"0\" allowfullscreen></iframe></div><div class=\"title\">#{@title}</div></div>"
  end

  Liquid::Template.register_tag "youtube", self
end
