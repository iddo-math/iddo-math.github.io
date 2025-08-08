---
title: "An Article with Custom Environments"
layout: "UGprob"
---

Here's an important result in {% ref pythagoras %}. The proof is quite elegant.

{% thm "Pythagorean Theorem" label="pythagoras" %}
In a right-angled triangle, the square of the hypotenuse is equal to the sum of the squares of the other two sides.
{% endthm %}

We can generalize this with the following lemma.

{% lem "Triangle Inequality" label="triangle_inequality" %}
For any triangle, the sum of the lengths of any two sides is greater than the length of the remaining side.
{% endlem %}

The formula is shown in {% eqref cosine_law %}.

{% eqn label="cosine_law" %}
$$ c^2 = a^2 + b^2 - 2ab \cos(\gamma) $$
{% endeqn %}

And now for an example related to the previous lemma.

{% xmpl "Application of the Triangle Inequality" %}
Let's consider a triangle with side lengths $a=3$, $b=4$, and $c=5$. Since $3+4 > 5$, this is a valid triangle.
{% endxmpl %}