module Jekyll
  # Use a Generator to ensure the content modification runs at a high priority
  class LatexEnvironmentsGenerator < Jekyll::Generator
    # Set a high priority to run before most other processors (like Markdown)
    priority :high 

    # Class variables to maintain state across all documents
    @@counters = Hash.new(0)
    @@section_counters = [0, 0, 0] # [section, subsection, subsubsection]
    @@labels = {}

    ENVIRONMENTS = %w[theorem lemma proposition example exercise proof]
    
    # Regex for sectioning commands
    SECTION_REGEX = /
      \\(section|subsection|subsubsection)(\*?)\s* \{([^{}]*?)\}
      (?:\\tlabel\{([\w:]+)\})?
    /xm


    def generate(site)
      # Reset all counters for a fresh build
      @@counters = Hash.new(0)
      @@section_counters = [0, 0, 0]
      @@labels = {}
      
      # Combine all documents into one array for cleaner looping
      all_documents = site.documents + site.pages

      # ==========================================================
      # FIRST PASS: Numbering, Storing Labels, and Content Replacement
      # ==========================================================
      all_documents.each do |doc|
        # Skip if no content exists
        next unless doc.content

        # Reset section counters for each new document (like a new chapter/page)
        @@section_counters = [0, 0, 0]
        
        # NEW: Initialize TOC data structure for the current document
        current_doc_toc = [] 

        # Process sections first, passing the array to collect TOC data
        doc.content = process_sections(doc.content, current_doc_toc) 
        
        # NEW: Store the collected TOC data in the document's data hash for Liquid access
        doc.data['latex_toc'] = current_doc_toc

        # Process environments next
        doc.content = process_environments(doc.content)
      end

      # ==========================================================
      # SECOND PASS: Reference Resolution (using all collected labels)
      # ==========================================================
      all_documents.each do |doc| 
        doc.content = replace_references(doc.content) if doc.content 
      end
    end

    # ==========================================================
    # MODIFIED: SECTION PROCESSING METHOD (accepts toc_array)
    # ==========================================================
    def process_sections(content, toc_array)
      content.gsub(SECTION_REGEX) do |match|
        command_name = $1    # 'section', 'subsection', or 'subsubsection'
        is_starred = !$2.empty?
        title = $3
        label_key = $4

        # Determine the section level index (0, 1, or 2)
        level_index = case command_name
                      when 'section'     then 0
                      when 'subsection'  then 1
                      when 'subsubsection' then 2
                      else raise "Unknown section command: #{command_name}"
                      end
        
        # Map to the corresponding HTML heading tag (section -> h2, subsection -> h3, etc.)
        tag = "h#{level_index + 2}" 

        # --- Counter Logic ---
        section_number = nil
        if is_starred
          section_number = nil # No numbering for starred commands
        else
          # Reset lower-level counters (e.g., new section resets subsections/subsubsections)
          (level_index + 1).upto(2) { |i| @@section_counters[i] = 0 }
          
          # Increment current level counter
          @@section_counters[level_index] += 1

          # Generate the number string (e.g., '1', '1.2', or '1.2.3')
          number_parts = @@section_counters[0..level_index].map(&:to_s).reject { |n| n == '0' }
          section_number = number_parts.join('.')
          
          # NEW: Collect TOC data if it's a numbered section and has a label
          if label_key 
             toc_array << {
               'level'  => level_index + 2, # H2, H3, H4 used for indentation
               'number' => section_number,
               'title'  => title,
               'id'     => label_key # Anchor link target
             }
          end
        end

        # --- Label Storage ---
        if label_key && section_number
          @@labels[label_key] = section_number
        end

        # --- HTML Generation ---
        html_id = label_key ? "id=\"#{label_key}\"" : ""

        # Title includes the number if not starred
        numbered_title = section_number ? "#{section_number} #{title}" : title
        
        # Add the 'latex-section' class for styling
        "<#{tag} class='latex-section' #{html_id}>#{numbered_title}</#{tag}>"
      end
    end

    # ==========================================================
    # ENVIRONMENT PROCESSING METHOD (Unchanged)
    # ==========================================================
    def process_environments(content)
      ENVIRONMENTS.each do |env|
        
        # Regex to capture optional title, optional tlabel (in [tlabel=key]), and body
        regex = /\\begin\{#{env}\}\s*(?:\[(.*?)\])?\s*(?:\[tlabel=(.*?)\])?(.*?)\s*\\end\{#{env}\}/m
        
        content.gsub!(regex) do |match|
          title, label, body = $1, $2, $3.strip

          # Check for \tlabel{...} command embedded inside the body
          body.gsub!(/\\tlabel\{(.*?)\}/) do |label_match|
            label ||= $1
            "" # Remove the label from the body
          end

          # Increment flat counter and set number
          @@counters[env] += 1
          number = @@counters[env]

          # Store the label reference
          if label
            # Store the full reference string (e.g., 'Theorem 1')
            @@labels[label] = "#{env.capitalize} #{number}"
          end

          # Create the HTML structure
          heading = "<strong>#{env.capitalize} #{number}" + (title ? ": #{title}" : "") + "</strong>"

          # Return the HTML block
          <<~HTML
            <div class="latex-env #{env}" id="#{label}">
              #{heading}. 
              
              #{body}
            
            </div>
          HTML
        end
      end
      
      return content
    end

    # ==========================================================
    # REFERENCE RESOLUTION METHOD (Unchanged)
    # ==========================================================
    def replace_references(content)
      # Replace \ref{label} with stored reference, which could be "1.2.1" or "Theorem 5"
      content.gsub!(/\\ref\{(.*?)\}/) do |match|
        label_id = $1

        # Replace \ref{label_id} with a hyperlink or an error message
        if @@labels.key?(label_id)
          # The value is the section number (e.g., '1.2') or the full reference string (e.g., 'Theorem 5')
          # Create the hyperlink using the stored value and the label_id as the anchor.
          "<a href=\"##{label_id}\" class=\"reference-link\">#{@@labels[label_id]}</a>"
        else
          # Error fallback
          "<strong class='unresolved-ref'>??</strong>"
        end
      end
      
      return content
    end
  end
end
