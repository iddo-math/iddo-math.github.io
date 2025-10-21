module Jekyll
  # Use a Generator to ensure the content modification runs at a high priority
  class LatexEnvironmentsGenerator < Jekyll::Generator
    # Set a high priority to run before most other processors (like Markdown)
    priority :high 

    # Class variables to maintain state across all documents
    @@counters = Hash.new(0)
    @@section_counters = [0, 0, 0] # [section, subsection, subsubsection]
    @@labels = {}
    
    # --- Environment Configuration Table ---
    ENV_CONFIG = {
      'thm'   => { 'display' => 'Theorem', 'counter' => 'thm' },
      'lem'   => { 'display' => 'Lemma', 'counter' => 'thm' },
      'prop'  => { 'display' => 'Proposition', 'counter' => 'thm' },
      'defn'  => { 'display' => 'Definition' },
      'xmpl'  => { 'display' => 'Example' },
      'exer'  => { 'display' => 'Exercise' },
      'prob'  => {'display' => 'Problem'    },
      'rem'   => { 'display' => 'Remark', 'counter' => nil },
      'pf'    => { 'display' => 'Proof', 'counter' => nil } # Proofs are now collapsible and have QED
    }.freeze
    
    ENV_NAMES = ENV_CONFIG.keys.join('|')
    
    # Regex for sectioning commands.
    SECTION_REGEX = /
      \\(section|subsection|subsubsection)(\*?)\s* \{([^{}]*?)\}
      (?:\\tlabel\{([\w:]+)\})?
    /xm
    
    # Helper to escape Liquid syntax from content before processing.
    private
    def escape_liquid_delimiters(text)
      text.gsub('{{', '{{ "{{" }}').gsub('{%', '{{ "{%" }}')
    end

    public
    def generate(site)
      # Reset all counters for a fresh build
      @@counters = Hash.new(0)
      @@section_counters = [0, 0, 0]
      @@labels = {}
      
      # FIX: Ensure markdown converter is available
      @markdown_converter = site.converters.find { |c| c.class.ancestors.include?(Jekyll::Converters::Markdown) }
      
      if @markdown_converter.nil?
        begin
          @markdown_converter = Jekyll::Converters::Markdown.new(site.config) 
        rescue NameError
          Jekyll.logger.error "LatexEnvironmentsGenerator:", "Cannot instantiate Markdown converter."
          @markdown_converter = nil 
        end
      end

      all_documents = site.documents + site.pages

      # ==========================================================
      # FIRST PASS: Numbering, Storing Labels, and Content Replacement
      # ==========================================================
      all_documents.each do |doc|
        # FIX: Guarantee content is a string using .to_s to prevent the nil error
        content = doc.content.to_s 

        @@section_counters = [0, 0, 0]
        section_id_ref = [0] 

        content = process_sections(content, section_id_ref) 
        content = process_environments(content) 

        doc.content = content # Assign the (guaranteed string) result back
      end

      # ==========================================================
      # SECOND PASS: Reference Resolution (using all collected labels)
      # ==========================================================
      all_documents.each do |doc| 
        # FIX: Guarantee content is a string using .to_s
        content = doc.content.to_s
        doc.content = replace_references(content)
      end
    end

    # ==========================================================
    # SECTION PROCESSING METHOD
    # ==========================================================
    def process_sections(content, section_id_ref)
      # Uses safe gsub
      content.gsub(SECTION_REGEX) do |match|
        command_name = $1
        is_starred = !$2.empty?
        title = $3
        user_label_key = $4

        level_index = case command_name
                      when 'section'      then 0
                      when 'subsection'   then 1
                      when 'subsubsection' then 2
                      else raise "Unknown section command: #{command_name}"
                      end
        
        markdown_prefix = '#' * (level_index + 1)

        section_id_ref[0] += 1 
        label_key = user_label_key.nil? || user_label_key.empty? ? "sec:id-#{section_id_ref[0]}" : user_label_key

        section_number = nil
        escaped_title = escape_liquid_delimiters(title)

        if is_starred
          numbered_title = escaped_title
        else
          (level_index + 1).upto(2) { |i| @@section_counters[i] = 0 }
          
          @@section_counters[level_index] += 1

          number_parts = @@section_counters[0..level_index].map(&:to_s).reject { |n| n == '0' }
          section_number = number_parts.join('.')
          
          @@labels[label_key] = section_number
          
          numbered_title = "#{section_number} #{escaped_title}"
        end

        "#{markdown_prefix} #{numbered_title} {##{label_key}}"
      end
    end

    # ==========================================================
    # ENVIRONMENT PROCESSING METHOD (Theorems, etc.)
    # ==========================================================
    def process_environments(content) 
      master_regex = /
        \\begin\{(#{ENV_NAMES})\}\s* (?:\[(.*?)\])? (.*?) \s* \\end\{\1\}
      /xm

      # FIX: Use safe gsub and return the result
      content.gsub(master_regex) do |match|
        short_name, title, body = $1, $2, $3.strip
        config = ENV_CONFIG[short_name]

        # 1. Configuration/Label Extraction
        display_name = config['display']
        counter_name = config.fetch('counter', short_name)
        counter_name = nil unless counter_name.is_a?(String)
        label = nil

        # Check for \tlabel{...} command embedded inside the body
        body.gsub!(/\\tlabel\{(.*?)\}/) do |label_match|
          label ||= $1
          "" # Remove the label from the body
        end

        # --- Numbering Logic (Unchanged) ---
        number = nil
        if counter_name
          @@counters[counter_name] += 1
          number = @@counters[counter_name]
          @@labels[label] = "#{display_name} #{number}" if label
        end

        # --- Content Conversion ---
        heading_text = number ? "#{display_name} #{number}" : display_name
        
        escaped_title = title ? escape_liquid_delimiters(title) : nil
        escaped_body = escape_liquid_delimiters(body)

        title_html = if escaped_title && @markdown_converter
        converted = @markdown_converter.convert(escaped_title).strip
        converted.gsub(/^<p>(.*)<\/p>$/m, '\1')
else
  title
end
        heading = "<strong>#{heading_text}" + (title_html ? ": #{title_html}" : "") + "</strong>"

        html_body = @markdown_converter ? @markdown_converter.convert(escaped_body).strip : escaped_body

        # -----------------------------------------------
        # NEW LOGIC: Proof Environment Enhancements
        # -----------------------------------------------
        label_id_attr = label ? "id=\"#{label}\"" : ""
        is_collapsible = ['pf'].include?(short_name)
        toggle_class = is_collapsible ? ' collapsible' : ''
        content_id_key = "env-body-#{label || short_name}-#{@@counters[counter_name || short_name]}"
        
        if short_name == 'pf'
          # Add the QED box ($\blacksquare$)
          qed_box = '<span class="qed-box">&#x25A0;</span>'
          html_body << qed_box
        end

        if is_collapsible
          # Add a toggle button to the heading
          collapse_button = <<-HTML
            <button class="collapse-toggle" aria-expanded="false" aria-controls="#{content_id_key}">
              <span class="plus-icon">+</span>
              <span class="minus-icon">-</span>
            </button>
          HTML
          heading = collapse_button + heading
        end
        
        # Return the final HTML block
        <<~HTML
          <div class="latex-env #{short_name}#{toggle_class}" #{label_id_attr}>
            <div class="env-heading">
              #{heading}. 
            </div>
            
            <div class="env-content" id="#{content_id_key}">
              #{html_body}
            </div>
          </div>
        HTML
      end
    end

    # ==========================================================
    # REFERENCE RESOLUTION METHOD
    # ==========================================================
def replace_references(content)
  # Updated Regex:
  # 1. \\ref\{ - Matches the literal start of the command
  # 2. (.*?) - Captures Group 1 (label_id) - non-greedy match
  # 3. \} - Matches the closing brace
  # 4. (?:\[(.*?)\])? - Non-capturing group for the optional part [Custom Text]
  #    - \[ - Matches literal opening bracket
  #    - (.*?) - Captures Group 2 (optional_text) - non-greedy match
  #    - \] - Matches literal closing bracket
  #    - ? - Makes the entire bracket group optional

  regex = /\\ref\{(.*?)\}(?:\[(.*?)\])?/
  
  # FIX: Use safe gsub and return the result
  content.gsub(regex) do |match|
    label_id = $1
    optional_text = $2 # This will be the content inside the optional brackets, or nil
    
    # Determine the fallback text if the label is unresolved
    # If optional_text is provided, use it. Otherwise, use the error text '??'
    fallback_text = optional_text || "<strong class='unlabeled-ref'>??</strong>"

    if @@labels.key?(label_id)
      # CASE 1: Label IS resolved. Use the stored reference text.
      # Ignore the optional_text parameter for resolved labels (Standard LaTeX behavior)
      link_text = @@labels[label_id]
      
      "<a href=\"##{label_id}\" class=\"reference-link\">#{link_text}</a>"
    else
      # CASE 2: Label is NOT resolved. Use the fallbaack text.
      "<a href=\"##{label_id}\" class=\"generic-link\">#{fallback_text}</a>"
    end
  end
end
  end
end