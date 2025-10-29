---
title: Undergraduate Probability
layout: latex
---

Welcome to my online Undergraduate probability textbook! 

I'm still working on converting the book from its old form  **and I'm still testing it**. Images are missing, some links point to the wrong place, and there are additioal issues, but nearly all content is there.  

{% comment %} 
    1. CRITICAL: Use the 'page.dir' variable to get the current file's directory path (e.g., '/probability/').
    This is the most reliable way to filter files.
{% endcomment %}
{% assign target_dir = page.dir %}

<h2 id="table-of-contents">Table of Contents</h2>

<ul class="file-list">
  {% comment %} 
      2. Iterate through all standard pages on the site.
  {% endcomment %}
  {% for file in site.pages %}
    
    {% comment %} 
        3. Filter:
           a) Check if the file's directory (file.dir) EXACTLY matches the current directory (target_dir).
           b) Check that the file is NOT the current page itself (file.path != page.path).
           c) (Optional but safe) Ensure the file has an output URL (meaning it's a renderable page).
    {% endcomment %}
    {% if file.dir == target_dir and file.path != page.path and file.url %}
      
      <li>
        <a href="{{ file.url | relative_url }}">
          {% comment %} 
              4. Display the title from the file's front matter.
              The 'default' filter provides a fallback title if the front matter is missing the 'title' field.
          {% endcomment %}
          {{ file.title | default: file.name | replace: '.md', '' | replace: '-', ' ' | capitalize }}
        </a>
      </li>
      
    {% endif %}
  {% endfor %}
</ul>