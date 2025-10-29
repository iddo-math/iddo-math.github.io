# _plugins/latex_environments_generator.rb
# Jekyll generator: robust MathJax handling + sections + theorem-like environments.
#
# Features:
# - Converts legacy inline math ($...$ and \( ... \)) to a unique delimiter @@@...@@@
#   and shields with {::nomarkdown} so Markdown/Kramdown doesn't alter contents.
# - Shields $$...$$ display math in {::nomarkdown} and enforces blank lines around.
# - Renders theorem-like environments (\begin{lem}...\end{lem}, etc.) to HTML
#   and fences them with {::nomarkdown} (blank-line safe).
# - Provides \section-like numbering + labels and \ref{...} resolution.
#   By default, \ref to sections shows the SECTION TITLE (not the number).
#   \ref to environments (e.g., lemmas) shows their display text ("Lemma 3").
# - Skips rewrites inside fenced code ```...```, inline `code`, <code>...</code>,
#   Liquid {% raw %}...{% endraw %}, and existing {::nomarkdown} regions.
#
# Optional site config (_config.yml) – defaults shown:
#
#   mathjax_inline_delimiter: "@@@"
#   allow_legacy_inline_dollar: true
#   allow_legacy_inline_paren:  true
#   shield_display_math:        true
#
# After installing this plugin, configure MathJax to use ONLY the custom inline
# delimiter for inline math and $$ for display (see snippet in your layout).

module Jekyll
  class LatexEnvironmentsGenerator < Jekyll::Generator
    priority :high

    # ---------- Class-level persistent state ----------
    @@labels = {}

    # ---------- Theorem-like environments configuration ----------
    ENV_CONFIG = {
      'thm'  => { 'display' => 'Theorem',     'counter' => 'thm'  },
      'lem'  => { 'display' => 'Lemma',       'counter' => 'thm'  },
      'prop' => { 'display' => 'Proposition', 'counter' => 'thm'  },
      'cor'  => { 'display' => 'Corollary',   'counter' => 'thm'  },
      'defn' => { 'display' => 'Definition',  'counter' => 'defn' },
      'xmpl' => { 'display' => 'Example',     'counter' => 'xmpl' },
      'exer' => { 'display' => 'Exercise',    'counter' => 'exer' },
      'prob' => { 'display' => 'Problem',     'counter' => 'prob' },
      'rem'  => { 'display' => 'Remark',      'counter' => nil    },
      'pf'   => { 'display' => 'Proof',       'counter' => nil    }
    }.freeze

    ENV_NAMES = ENV_CONFIG.keys.join('|')

    # \section-like commands with optional star and optional \label{...}
    SECTION_REGEX = %r{
      \\(section|subsection|subsubsection)(\*?)\s*   # 1: name, 2: star?
      \{([^\{\}]*?)\}                                # 3: title
      (?:\s*\\label\{([\w:\-]+)\})?                  # 4: optional label
    }xm

    def generate(site)
      @@labels.clear
      all_documents = site.documents + site.pages

      @markdown_converter = site.converters.find { |c|
        c.class.ancestors.include?(Jekyll::Converters::Markdown)
      }

      # Site-level options (with defaults)
      @inline_delim        = site.config['mathjax_inline_delimiter'] || '@@@'
      @legacy_dollar       = site.config.key?('allow_legacy_inline_dollar') ? !!site.config['allow_legacy_inline_dollar'] : true
      @legacy_paren        = site.config.key?('allow_legacy_inline_paren')  ? !!site.config['allow_legacy_inline_paren']  : true
      @shield_display_math = site.config.key?('shield_display_math')        ? !!site.config['shield_display_math']        : true

      # PASS 1: pre-normalize math, then process sections/envs
      all_documents.each do |doc|
        next if doc.content.nil?

        content = doc.content.to_s.dup

        # A) Shield $$...$$ display math (prevents reflow in lists/tight paragraphs)
        content = rewrite_display_math_blocks(content) if @shield_display_math

        # B) Rewrite inline math to custom delimiter and shield
        content = rewrite_inline_math_spans_to_custom(content)

        # C) Sections and environments
        section_counters = [0, 0, 0]
        document_counters = Hash.new(0)
        document_env_instance_id = [0]
        section_id_ref = [0]

        content = process_sections(content, section_id_ref, section_counters)
        content = process_environments(content, document_counters, document_env_instance_id)

        doc.content = content
      end

      # PASS 2: resolve \ref{...}
      all_documents.each do |doc|
        next if doc.content.nil?
        content = doc.content.to_s
        content = replace_references(content)
        doc.content = content
      end
    end

    private

    # --- Utility: escape Liquid delimiters inside user content ---
    def escape_liquid_delimiters(text)
      text.to_s.gsub('{{', '{{ "{ {" }}').gsub('{%', '{{ "{%" }}')
    end
    def escape_kramdown_problematic_chars(text)
      # Escapes the pipe symbol (|) to its HTML entity (&#124;) to prevent Kramdown
      # from misinterpreting it as a table separator in inline math.
     text.to_s.gsub('|', '&#124;').gsub('<', '&lt;').gsub('>', '&gt;')
    end
    # --- Split into protected and unprotected regions ---
    # Protected:
    #   - fenced code blocks ```...```
    #   - Liquid {% raw %}...{% endraw %}
    #   - existing {::nomarkdown}...{:/nomarkdown}
    def split_protected(src)
      pattern = %r{
        (                                     # 1: any protected chunk
          ^```[^\n]*\n.*?\n```[ \t]*\n?       # fenced code block
          | \{\%\s*raw\s*\%\}.*?\{\%\s*endraw\s*\%\}    # Liquid raw
          | \{::nomarkdown\}.*?\{:/nomarkdown\}         # already shielded
        )
      }mx

      parts, last = [], 0
      src.scan(pattern) do
        m = Regexp.last_match
        parts << { protected: false, text: src[last...m.begin(0)] } if m.begin(0) > last
        parts << { protected: true,  text: m[0] }
        last = m.end(0)
      end
      parts << { protected: false, text: src[last..-1] } if last < src.length
      parts
    end

    # Further split non-protected text into (inline code spans | <code>...</code>) vs text
    def split_inline_code_and_text(text)
      tokens = []
      i = 0
      re = /(`+[^`]*?`+|<code\b[^>]*>.*?<\/code>)/m
      text.scan(re) do
        m = Regexp.last_match
        if m.begin(0) > i
          tokens << { code: false, text: text[i...m.begin(0)] }
        end
        tokens << { code: true,  text: m[0] }
        i = m.end(0)
      end
      tokens <<({ code: false, text: text[i..-1] }) if i < text.length
      tokens
    end

    # --- Display math: shield $$...$$ with {::nomarkdown} + blank lines ---
    def rewrite_display_math_blocks(src)
      return src if src.to_s.empty?

      split_protected(src).map { |piece|
        if piece[:protected]
          piece[:text]
        else
          piece[:text].gsub(%r{(?<!\\)\$\$(.+?)(?<!\\)\$\$}m) do
            inner = escape_kramdown_problematic_chars(Regexp.last_match(1))
            "\n\n{::nomarkdown}\n$$#{inner}$$\n{:/nomarkdown}\n\n"
          end
        end
      }.join
    end

    # --- Inline math: normalize to custom delimiter and shield ---
    # Converts:
    #   - @@@...@@@ (already preferred)  -> shielded form
    #   - \( ... \)  (legacy, if enabled) -> shielded @@@...@@@
    #   - $...$     (legacy, if enabled)  -> shielded @@@...@@@
    # Leaves \$ as literal dollar; skips code/raw/nomarkdown regions.
    def rewrite_inline_math_spans_to_custom(src)
      return src if src.to_s.empty?
      open_delim  = Regexp.escape(@inline_delim)
      close_delim = open_delim

      split_protected(src).map { |piece|
        if piece[:protected]
          piece[:text]
        else
          # Avoid touching inline code or <code>...</code>
          chunks = split_inline_code_and_text(piece[:text]).map do |tk|
            next tk[:text] if tk[:code]

            s = tk[:text]

            # 0) Shield already-correct custom inline delimiter occurrences
            s = s.gsub(/#{open_delim}(.+?)#{close_delim}/m) do
             inner = escape_kramdown_problematic_chars(Regexp.last_match(1))
              "{::nomarkdown}#{@inline_delim}#{inner}#{@inline_delim}{:/nomarkdown}"
            end

            # 1) legacy \( ... \) -> custom
            if @legacy_paren
              s = s.gsub(/\\\((.+?)\\\)/m) do
                inner = escape_kramdown_problematic_chars(Regexp.last_match(1))
                "{::nomarkdown}#{@inline_delim}#{inner}#{@inline_delim}{:/nomarkdown}"
              end
            end

            # 2) legacy $...$ (unescaped single dollars, not $$, not \$)
            if @legacy_dollar
              s = s.gsub(/(?<!\\)\$(?!\$)(.+?)(?<!\\)\$(?!\$)/m) do
                inner = escape_kramdown_problematic_chars(Regexp.last_match(1))
                "{::nomarkdown}#{@inline_delim}#{inner}#{@inline_delim}{:/nomarkdown}"
              end
            end

            s
          end
          chunks.join
        end
      }.join
    end

    # --- Sections -> Markdown headings, with numbering, labels, and label metadata ---
    # Stores label metadata so \ref{...} can render the TITLE by default.
    def process_sections(content, section_id_ref, section_counters)
      content.gsub(SECTION_REGEX) do
        cmd, star, title, user_label = $1, $2, $3, $4
        level_index = %w[section subsection subsubsection].index(cmd)
        markdown_prefix = '#' * (level_index + 1)

        section_id_ref[0] += 1
        label_key = user_label.to_s.empty? ? "sec:id-#{section_id_ref[0]}" : user_label
        escaped_title = escape_liquid_delimiters(title)

        if star && !star.empty?
          # Unnumbered (starred) sections: show title only
          @@labels[label_key] = {
            kind:   'section',
            number: nil,
            title:  escaped_title
          }
          numbered_title = escaped_title
        else
          # Numbered sections
          (level_index + 1).upto(2) { |i| section_counters[i] = 0 }
          section_counters[level_index] += 1
          parts = section_counters[0..level_index].map(&:to_s).reject { |n| n == '0' }
          section_number = parts.join('.')

          @@labels[label_key] = {
            kind:   'section',
            number: section_number,
            title:  escaped_title
          }
          numbered_title = "#{section_number} #{escaped_title}"
        end

        "#{markdown_prefix} #{numbered_title} {##{label_key}}"
      end
    end

    # --- Theorem-like environments ---
    def process_environments(content, document_counters, document_env_instance_id)
      master_regex = %r{
        \\begin\{(#{ENV_NAMES})\}\s*     # 1: env name
        (?:\[(.*?)\])?                   # 2: optional title
        (.*?)                            # 3: body
        \\end\{\1\}                      # end
      }xm

      content.gsub(master_regex) do
        short, title, body = $1, $2, $3

        config = ENV_CONFIG[short]
        label = nil

        # OLD: extract \label{...} inside body
        #body = body.gsub(%r{\\label\{(.*?)\}}) do
        #  label = $1
        #  ''
        #end

        # New: only consider \label in the first line of the body.
        first_line, *rest_of_body = body.split("\n", 2)
        label_match = first_line.match(%r{\\label\{(.*?)\}})
        if label_match
          # The match object found something!
          label = label_match[1] # Extract the ID (e.g., "eq:1")
         first_line.sub!(label_match[0], '')
        end
        body = ([first_line] + rest_of_body).join("\n")
        # End new


        counter_name = config['counter']
        display_name = config['display']
        full_number = nil
        if counter_name
          document_counters[counter_name] += 1
          full_number = document_counters[counter_name].to_s
        end

        # Save label metadata for \ref
        if label
          display_text = full_number ? "#{display_name} #{full_number}" : display_name
          @@labels[label] = {
            kind:    'environment',
            number:  full_number,
            title:   display_name,   # base name like "Lemma", "Theorem"
            display: display_text
          }
        end

        heading_text = full_number ? "#{display_name} #{full_number}" : display_name

        # Convert title via Markdown->HTML (strip an outer <p>...</p> if present)
        title_html =
          if title && @markdown_converter
            t = @markdown_converter.convert(escape_liquid_delimiters(title)).strip
            t.sub(%r{\A<p>(.*)</p>\z}m, '\1')
          else
            title
          end

        # Convert body via Markdown; fence the whole block so we don't unwrap paragraphs
        html_body =
          if @markdown_converter
            @markdown_converter.convert(escape_liquid_delimiters(body)).strip
          else
            escape_liquid_delimiters(body)
          end

        # QED box for proofs
        html_body << ' <span class="qed-box">&#x25A0;</span>' if short == 'pf'

        document_env_instance_id[0] += 1
        instance_id   = document_env_instance_id[0]
        label_id_attr = label ? "id=\"#{label}\"" : "id=\"env-#{instance_id}\""
        is_collapsible = (short == 'pf')
        toggle_class   = is_collapsible ? ' collapsible' : ''
        content_id_key = label ? "#{label}-body" : "env-body-#{instance_id}"

        collapse_button = ''
        if is_collapsible
          collapse_button = <<~HTML
            <button class="collapse-toggle" aria-expanded="false" aria-controls="#{content_id_key}">
              <span class="plus-icon">+</span>
              <span class="minus-icon">-</span>
            </button>
          HTML
        end

        heading_html = "#{collapse_button}<strong>#{heading_text}#{title_html ? ": #{title_html}" : ''}</strong>"

        block_html = <<~HTML
          <div class="latex-env #{short}#{toggle_class}" #{label_id_attr}>
            <div class="env-heading">
              #{heading_html}.
            </div>
            <div class="env-content" id="#{content_id_key}">
              #{html_body}
            </div>
          </div>
        HTML

        # Fence with nomarkdown and add blank lines to make it an HTML block
        "\n\n{::nomarkdown}\n#{block_html}{:/nomarkdown}\n\n"
      end
    end
    # --- \ref{...} resolution ---
    # - If optional text is provided: use it.
    # - If kind == 'section': show the SECTION TITLE by default.
    # - If kind == 'environment': show the prebuilt display text (e.g., "Lemma 3").
    def replace_references(content)
      regex = %r{\\ref\{(.*?)\}(?:\[(.*?)\])?}
      content.gsub(regex) do
        label_id, optional_text = $1, $2

        entry = @@labels[label_id]

        # 1) If author provided custom text, use it regardless of kind
        link_text =
          if optional_text && !optional_text.strip.empty?
            optional_text
          else
            case entry
            when Hash
              if entry[:kind] == 'section'
                entry[:number] ? "#{entry[:number]} #{entry[:title]}" : entry[:title]
              elsif entry[:kind] == 'environment'
                entry[:display] || entry[:title] || '??'
              else
                entry[:display] || entry[:title] || entry[:number] || '??'
              end
            else
              # Backwards compatibility: if entry is a String (old behavior), show it
              entry || '??'
            end
          end

        href = "##{label_id}"
        "<a href=\"#{href}\" class=\"reference-link\">#{link_text}</a>"
      end
    end
  end
end
