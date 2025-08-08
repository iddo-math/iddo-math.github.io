# _plugins/math_environments.rb

# This Jekyll plugin defines custom Liquid tags for
# theorem-like environments, examples, equations, and references.
# It maintains separate counters and a site-wide reference hash.

# The `title_and_label` method is a helper to parse the arguments
def title_and_label(markup)
    # This regex captures a title and an optional label
    if markup =~ /^(.*)\s+label=\"([^\"]+)\"/
      title = $1.strip
      label = $2
    else
      title = markup.strip
      label = nil
    end
    [title, label]
  end
  
  # Base class for all numbered environments (thm, prop, lem, cor, xmpl, exer, prob)
  class NumberedBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @tag_name = tag_name
      @title, @label = title_and_label(markup)
    end
  
    def render(context)
      site = context.registers[:site]
      page_url = context['page']['url']
  
      # Initialize counters and references if they don't exist
      site.data['counters'] ||= Hash.new(0)
      site.data['references'] ||= {}
  
      # Get the counter for this specific environment type
      site.data['counters'][@tag_name] += 1
      number = site.data['counters'][@tag_name]
  
      # Convert the inner Markdown content to HTML
      converter = site.find_converter_from_ext("md")
      content = super
      body = converter.convert(content.strip)
  
      # Store the reference data if a label is provided
      if @label
        anchor_id = "#{@tag_name}-#{@label}"
        site.data['references'][@label] = {
          'type' => @tag_name,
          'number' => number,
          'title' => @title,
          'url' => "#{page_url}##{anchor_id}"
        }
      end
  
      # Generate the final HTML output
      anchor_tag = @label ? "id=\"#{anchor_id}\"" : ""
      title_html = @title.empty? ? "" : ": <span class=\"env-title\">#{@title}</span>"
  
      <<~HTML
        <div class="#{@tag_name}-env" #{anchor_tag}>
          <p class="#{@tag_name}-header">
            <strong class="env-type">#{@tag_name.capitalize} #{number}</strong>#{title_html}
          </p>
          <div class="env-body">
            #{body}
          </div>
        </div>
      HTML
    end
  end
  
  # Specific classes for each numbered environment
  class ThmBlock < NumberedBlock; end
  class PropBlock < NumberedBlock; end
  class LemBlock < NumberedBlock; end
  class CorBlock < NumberedBlock; end
  class XmplBlock < NumberedBlock; end
  class ExerBlock < NumberedBlock; end
  class ProbBlock < NumberedBlock; end
  
  # Class for equations with a single, site-wide counter
  class EqnBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @label = markup.strip.gsub('label=', '').gsub('"', '')
    end
  
    def render(context)
      site = context.registers[:site]
      page_url = context['page']['url']
  
      site.data['counters'] ||= Hash.new(0)
      site.data['references'] ||= {}
  
      site.data['counters']['eqn'] += 1
      number = site.data['counters']['eqn']
  
      converter = site.find_converter_from_ext("md")
      content = super
      body = converter.convert(content.strip)
  
      if @label
        anchor_id = "eq-#{@label}"
        site.data['references'][@label] = {
          'type' => 'Equation',
          'number' => number,
          'url' => "#{page_url}##{anchor_id}"
        }
      end
  
      anchor_tag = @label ? "id=\"#{anchor_id}\"" : ""
  
      <<~HTML
        <div class="equation-env" #{anchor_tag}>
          <span class="equation-number">(#{number})</span>
          <div class="equation-body">
            #{body}
          </div>
        </div>
      HTML
    end
  end
  
  # Class for a general reference tag
  class RefTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @label = markup.strip
    end
  
    def render(context)
      site = context.registers[:site]
      reference = site.data['references'][@label]
  
      if reference
        "#{reference['type'].capitalize} #{reference['number']}: <a href=\"#{reference['url']}\">#{reference['title']}</a>"
      else
        "<strong>[Reference not found: '#{@label}']</strong>"
      end
    end
  end
  
  # Class for an equation reference tag
  class EqRefTag < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @label = markup.strip
    end
  
    def render(context)
      site = context.registers[:site]
      reference = site.data['references'][@label]
  
      if reference
        "<a href=\"#{reference['url']}\">(#{reference['number']})</a>"
      else
        "<strong>[Equation reference not found: '#{@label}']</strong>"
      end
    end
  end
  
  # Register all the tags
  Liquid::Template.register_tag('thm', Jekyll::ThmBlock)
  Liquid::Template.register_tag('prop', Jekyll::PropBlock)
  Liquid::Template.register_tag('lem', Jekyll::LemBlock)
  Liquid::Template.register_tag('cor', Jekyll::CorBlock)
  Liquid::Template.register_tag('xmpl', Jekyll::XmplBlock)
  Liquid::Template.register_tag('exer', Jekyll::ExerBlock)
  Liquid::Template.register_tag('prob', Jekyll::ProbBlock)
  Liquid::Template.register_tag('eqn', Jekyll::EqnBlock)
  Liquid::Template.register_tag('ref', Jekyll::RefTag)
  Liquid::Template.register_tag('eqref', Jekyll::EqRefTag)
  