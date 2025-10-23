module Jekyll
  # Use a Generator to ensure the content modification runs at a high priority
  class LatexEnvironmentsGenerator < Jekyll::Generator
    # Set a high priority to run before most other processors (like Markdown)
    priority :high 

    # NOTE: @@labels is the ONLY class variable that MUST persist across ALL documents 
    # in Pass 1 to allow for the second pass (reference resolution) to work across the whole site.
    @@labels = {}
    
    # NEW: Global class variable to hold MathJax substitutions for all documents
    @@global_math_substitutions = {}
    
    # --- Environment Configuration Table ---
    ENV_CONFIG = {
      'thm'   => { 'display' => 'Theorem', 'counter' => 'thm' },
      'lem'   => { 'display' => 'Lemma', 'counter' => 'thm' },
      'prop'  => { 'display' => 'Proposition', 'counter' => 'thm' },
      'defn'  => { 'display' => 'Definition', 'counter' => 'defn' },
      'xmpl'  => { 'display' => 'Example', 'counter' => 'xmpl' },
      'exer'  => { 'display' => 'Exercise', 'counter' => 'exer' },
      'prob'  => {'display' => 'Problem', 'counter' => 'prob'    },
      'rem'   => { 'display' => 'Remark', 'counter' => nil },
      'pf'    => { 'display' => 'Proof', 'counter' => nil } # Proofs are now collapsible and have QED
    }.freeze
    
    ENV_NAMES = ENV_CONFIG.keys.join('|')
    
    # Regex for sectioning commands.
    SECTION_REGEX = /
      \\(section|subsection|subsubsection)(\*?)\s* \{([^{}]*?)\}
      (?:\\tlabel\{([\w:]+)\})?
    /xm
    
    # Regex to capture display math $$...$$ globally
    DISPLAY_MATH_REGEX = /\$\$(.+?)\$\$/m
    
    # Regex to capture inline math $...$ globally
    # Note: This is run AFTER display math is protected, making it safe.
    INLINE_MATH_REGEX = /\$(.+?)\$/m
    
    # NEW CONSTANT: Characters that must be escaped to prevent Markdown processing inside math.
    # We still list '|' here, but it will be handled as a special case in restore_mathjax.
    MARKDOWN_SPECIAL_CHARS_REGEX = /([*_|])/ 
    
    # Helper to escape Liquid syntax from content before processing.
    private
    def escape_liquid_delimiters(text)
      text.gsub('{{', '{{ "{{" }}').gsub('{%', '{{ "{%" }}')
    end
    
    # NEW: Function to replace math with placeholders
    private
    def protect_mathjax(content)
      math_placeholders = {}
      placeholder_count = 0
      
      # 1. Protect DISPLAY Math ($$...$$) first.
      # Using a placeholder format that is immune to Markdown formatting issues (e.g., underscores)
      protected_content = content.gsub(DISPLAY_MATH_REGEX) do |math_match|
        placeholder_count += 1
        placeholder = "[[MJPH-D-#{placeholder_count}]]" 
        math_placeholders[placeholder] = math_match 
        placeholder
      end
      
      # 2. Protect INLINE Math ($...$). This is now safe because all $$ markers are gone.
      protected_content.gsub!(INLINE_MATH_REGEX) do |math_match|
        placeholder_count += 1
        placeholder = "[[MJPH-I-#{placeholder_count}]]" 
        math_placeholders[placeholder] = math_match 
        placeholder
      end
      
      # Return content with placeholders and the map
      [protected_content, math_placeholders]
    end
    
    # NEW: Function to restore math from placeholders
    private
    def restore_mathjax(content, math_placeholders)
      restored_content = content.dup
      
      # The constant is now defined outside and used here:
      math_placeholders.each do |placeholder, original_math|
        
        # 1. Extract the content *inside* the math delimiters.
        is_display = placeholder.include?('-D-')
        # Remove delimiters to process content only
        math_content = original_math.sub(/^\$+/, '').sub(/\$+$/, '')
        
        # 2. Robustly escape the Markdown special characters inside the content.
        escaped_content = math_content.gsub(MARKDOWN_SPECIAL_CHARS_REGEX) do |match|
          if match == '|'
            # NO ESCAPING: The literal pipe must be passed through.
            # Any escaping here results in MathJax receiving '\' or '\\', which leads to '\|' (double bar).
            match 
          else
            # For '*' and '_', we need to pass '\\*' or '\\_' (double backslash) to Kramdown.
            # Kramdown consumes one backslash, leaving '\*' or '\_' for MathJax.
            "\\\\#{match}"
          end
        end
        
        # 3. Restore the original delimiters around the escaped content.
        restored_math = is_display ? "$$#{escaped_content}$$" : "$#{escaped_content}$"
        
        # 4. Substitute the placeholder.
        restored_content.gsub!(placeholder, restored_math)
      end
      restored_content
    end

    public
    def generate(site)
      # Reset ALL labels and math substitutions for a fresh build
      @@labels = {}
      @@global_math_substitutions = {}
      
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
      # PASS 1: Protection, Numbering, Storing Labels, and Content Replacement
      # ==========================================================
      all_documents.each do |doc|
        
        # 1. Global Math Protection: Hide all MathJax before processing
        content_before_protect = doc.content.to_s
        content, math_map = protect_mathjax(content_before_protect)
        @@global_math_substitutions[doc.url] = math_map
        
        # --- CRITICAL FIX: Per-Document Counter Resets ---
        # These are now fully isolated and reset for EACH document loop iteration.
        section_counters = [0, 0, 0] 
        document_counters = Hash.new(0) # Environment counters (thm, defn, etc.)
        document_env_instance_id = [0] # Generic unique ID generator
        
        section_id_ref = [0] 

        # 2. Processing (on placeholder-ridden content)
        content = process_sections(content, section_id_ref, section_counters) 
        content = process_environments(content, document_counters, document_env_instance_id) 

        doc.content = content # Assign the result (with placeholders) back
      end

      # ==========================================================
      # PASS 2: Reference Resolution (using all collected labels)
      # ==========================================================
      all_documents.each do |doc| 
        # FIX: Guarantee content is a string using .to_s
        content = doc.content.to_s
        doc.content = replace_references(content)
      end
      
      # ==========================================================
      # PASS 3: Global Math Restoration (after all other processing)
      # ==========================================================
      all_documents.each do |doc|
        next unless @@global_math_substitutions.key?(doc.url)
        doc.content = restore_mathjax(doc.content.to_s, @@global_math_substitutions[doc.url])
      end
    end

    # ==========================================================
    # SECTION PROCESSING METHOD (Reset logic removed)
    # ==========================================================
    def process_sections(content, section_id_ref, section_counters)
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
          (level_index + 1).upto(2) { |i| section_counters[i] = 0 }
          
          section_counters[level_index] += 1

          number_parts = section_counters[0..level_index].map(&:to_s).reject { |n| n == '0' }
          section_number = number_parts.join('.')
          
          @@labels[label_key] = section_number
          
          numbered_title = "#{section_number} #{escaped_title}"
          
          # OLD LOGIC REMOVED: Section-based environment counter reset is gone.
          # Numbering is now purely sequential within the page.
        end

        "#{markdown_prefix} #{numbered_title} {##{label_key}}"
      end
    end

    # ==========================================================
    # ENVIRONMENT PROCESSING METHOD (Theorems, etc.)
    # (Simplified to pure sequential page-local numbering)
    # ==========================================================
    def process_environments(content, document_counters, document_env_instance_id) 
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
        # Check if the counter is disabled (set to nil in ENV_CONFIG)
        counter_name = nil unless counter_name.is_a?(String)
        label = nil
        
        # Check for \tlabel{...} command embedded inside the body
        body.gsub!(/\\tlabel\{(.*?)\}/) do |label_match|
          label ||= $1
          "" # Remove the label from the body
        end

        # --- Numbering Logic (Simple Page-Local Sequential) ---
        number = nil
        full_number = nil
        
        if counter_name
          document_counters[counter_name] += 1 # Increment the page-local counter (Resets per page!)
          number = document_counters[counter_name]
          full_number = number.to_s # Simple sequential number (1, 2, 3...)

          @@labels[label] = "#{display_name} #{full_number}" if label
        end

        # --- Content Conversion ---
        heading_text = full_number ? "#{display_name} #{full_number}" : display_name
        
        escaped_title = title ? escape_liquid_delimiters(title) : nil
        raw_body = body # Start with the raw body (which contains global math placeholders)

        # 1. Run Liquid escaping and Markdown conversion on the placeholder-ridden title/body
        title_html = if escaped_title && @markdown_converter
          converted = @markdown_converter.convert(escaped_title).strip
          converted.gsub(/^<p>(.*)<\/p>$/m, '\1')
        else
          title
        end

        escaped_body_for_md = escape_liquid_delimiters(raw_body)
        html_body = @markdown_converter ? @markdown_converter.convert(escaped_body_for_md).strip : escaped_body_for_md
        
        # html_body and title_html now contain the final HTML, with global placeholders intact.

        heading = "<strong>#{heading_text}" + (title_html ? ": #{title_html}" : "") + "</strong>"
        
        # -----------------------------------------------
        # LOGIC: Ensure unique ID generation for all elements on this page
        # -----------------------------------------------
        document_env_instance_id[0] += 1
        instance_id = document_env_instance_id[0]
        
        label_id_attr = label ? "id=\"#{label}\"" : "id=\"env-#{instance_id}\""
        is_collapsible = ['pf'].include?(short_name)
        toggle_class = is_collapsible ? ' collapsible' : ''
        # Use the label for the content div ID if present, otherwise use the instance ID
        content_id_key = label ? label : "env-body-#{instance_id}"
        
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
