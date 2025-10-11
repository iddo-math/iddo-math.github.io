
# _plugins/latex_environments.rb

module Jekyll
  class LatexPreprocessor
    @@counters = Hash.new(0)
    @@labels = {}

    ENVIRONMENTS = %w[theorem lemma proposition example exercise proof]

    def self.process(content)
      ENVIRONMENTS.each do |env|
  # Regex: \begin{env}[title][label=...] (BODY) \end{env}
  # Note the use of `\s*` for flexible whitespace and `.*?` for non-greedy body.
  # The /m flag is crucial for multiline matches.
  content.gsub!(/\\begin\{#{env}\}\s*(?:\[(.*?)\])?\s*(?:\[label=(.*?)\])?(.*?)\s*\\end\{#{env}\}/m) do
    # ... your existing logic for $1, $2, $3 ...
         title, label, body = $1, $2, $3.strip

          # Extract \label{...} inside body if not provided in optional argument
          body.gsub!(/\label\{(.*?)\}/) do
            label ||= $1
            ""
          end

          @@counters[env] += 1
          number = @@counters[env]

          if label
            @@labels[label] = "#{env.capitalize} #{number}"
          end

          heading = "<strong>#{env.capitalize} #{number}" + (title ? ": #{title}" : "") + "</strong>"

          <<~HTML
            <div class="latex-env #{env}">
              #{heading}. #{body}
            </div>
          HTML
  end
end
    
# Replace 
ef{label} with stored reference
      content.gsub(/\ref\{(.*?)\}/) do
        @@labels[$1] || "??"
      end

      content
    end
  end

  Hooks.register [:pages, :documents], :pre_render do |doc|
    doc.content = LatexPreprocessor.process(doc.content)
  end
end
