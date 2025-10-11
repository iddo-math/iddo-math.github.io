# _plugins/latex_environments.rb

module Jekyll
  # Use a Generator to ensure the content modification runs at a high priority
  class LatexEnvironmentsGenerator < Jekyll::Generator
    # Set a high priority to run before most other processors (like Markdown)
    priority :high 

    # Class variables to maintain state across all documents
    @@counters = Hash.new(0)
    @@labels = {}

    ENVIRONMENTS = %w[theorem lemma proposition example exercise proof]

    def generate(site)
      # Reset counters for a fresh build
      @@counters = Hash.new(0)
      @@labels = {}
      
      # Process all documents (pages and posts)
      site.documents.each { |doc| doc.content = process_environments(doc.content) if doc.content }
      site.pages.each     { |page| page.content = process_environments(page.content) if page.content }

      # Note: We run the second pass for \ref here, after all documents have been processed 
      # and all labels have been collected.
      site.documents.each { |doc| doc.content = replace_references(doc.content) if doc.content }
      site.pages.each     { |page| page.content = replace_references(page.content) if page.content }
    end

    def process_environments(content)
      ENVIRONMENTS.each do |env|
        
        # NOTE ON REGEX:
        # - \\begin\{#{env}\} matches \begin{theorem}
        # - \s* allows for any whitespace, including newlines
        # - (?:\[(.*?)\])? matches the optional title [Title]
        # - (?:\[label=(.*?)\])? matches the optional label [label=my-label]
        # - (.*?) matches the environment body (non-greedy)
        # - \s*\\end\{#{env}\} matches the closing tag
        # - The /m flag is CRUCIAL for multiline content
        
        # Using /xm allows for comments and flexible whitespace in the regex itself
        regex = /\\begin\{#{env}\}\s*(?:\[(.*?)\])?\s*(?:\[label=(.*?)\])?(.*?)\s*\\end\{#{env}\}/m
        
        content.gsub!(regex) do |match|
          title, label, body = $1, $2, $3.strip

          # Extract \label{...} inside body if not provided in optional argument
          # This should run on the captured body, $3
          body.gsub!(/\\label\{(.*?)\}/) do |label_match|
            label ||= $1
            "" # Remove the label from the body
          end

          # Increment counter and set number
          @@counters[env] += 1
          number = @@counters[env]

          # Store the label reference
          if label
            @@labels[label] = "#{env.capitalize} #{number}"
          end

          # Create the HTML structure
          heading = "<strong>#{env.capitalize} #{number}" + (title ? ": #{title}" : "") + "</strong>"

          # Use a block to return the HTML
          <<~HTML
            <div class="latex-env #{env}" id="#{label}">
              #{heading}. #{body}
            </div>
          HTML
        end
      end
      
      return content
    end

    def replace_references(content)
      # Replace \ref{label} with stored reference, e.g., "Theorem 1"
      content.gsub(/\\ref\{(.*?)\}/) do
        @@labels[$1] || "<strong class='unresolved-ref'>??</strong>"
      end
    end
  end
end
