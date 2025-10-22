---
title: Probability Spaces
layout: latex
---
# Introduction
When someone tells you that the probability of something happening is so and so what do they actually mean? 
(Let's assume that person is "properly trained" in the mathematical theory of probability. Otherwise, my answer below is has lower probability of being correct). 

Here's what they mean: 

* They are observing some experiment (it could be rolling a die, a soccer match, spread of an epidemic, change in crude oil prices a week from today) whose outcome is (usually) not known in advance, but is in some set of possible outcomes (e.g. the number appearing on the top when rolling a die).
* "something" refers to a collection of one or more possible outcomes ("even", "$70\%$ of the population of NYC will be infected by tomorrow", "the price of a barrel will not exceed $\\$75$"), which they can determine whether occurred or not after their observation is complete. Such sets are known as "events". 
* They have a mathematical model that assigns a numerical weight to each event, the weight being a number between $0$ and $1$ ($0\%$ to $100\%$), that can be interpreted as a quantitative measurement of "likelihood" or "chance" of the event, AKA "probability" of the event.  You can think of the model as a mathematical scale, weighing each possible event. When an event weighs zero it is essentially not observable, and when it weighs one it is guaranteed to be observed, and then there's in between: a range of uncertainty...  The probability can be also viewed as a (careful form of) prediction.  That's it. It is important to understand that the probability assigned is dictated by the model used. Very often we all agree on the model (fair die or fair coin), but this is not always the case. Did you ever notice that Weather.com, NOAA and Weather Underground very often give different "chances of rain" for the same day? If not, try right now. 

In this chapter we will explore the mathematical framework for what we just described, particularly the structure of the mathematical models assigning probabilities, AKA probability spaces. 

A probability space consists of three components we will now try to briefly explain. 

1. **[The sample space](#Sample Spaces)**. This is a set including all possible outcomes for the experiment. 
  : The experiment should be thought of a mechanism resulting in an outcome. This mechanism is often not fully understood (how financial markets work) or is too complex (we know all physics involving rolling a die, yet still we cannot predict what will happen when we roll it), and can be thought of the "randomness". Whatever the mechanism is at the end it spits out an outcome (value of your portfolio at the end of the year, the number on the top of the die). This procedure of obtaining an outcome is known as **sampling**, and the collection of all possible outcomes is the **sample space**. To visualize the sample space and the sampling, think of a claw machine, with sample space being all prize plus on more element a "null" prize. The sampling is the procedure of playing the game, and the outcome of each sampling is the prize. ![A Claw Crane game machine machine containing unicorn plushes in Trouville, France, Sept 2011](A Claw Crane game machine machine containing unicorn plushes in Trouville, France, Sept 2011.jpg) 
2. **[The sigma-algebra (or $\sigma$-algera)](#Events and sigma-algebras)** (just a name, don't dwell on it yet). This represents the information the observer has on the outcome at the conclusion of the observation. In some cases, the observer may not have complete information on the outcome. An **event** is a statement ("coin landed Heads") we will be able to determine as true or false at the conclusion of our observation regardless of the outcome, and the sigma-algebra is the collection of all events.  To understand the concept, let's think of the following case. Two dice are rolled. The sample space therefore $\Omega= \\{1,\dots,6\\}^2 = \\{(i,j):i,j \in \\{1,\dots,6\\}\\}$. We, as the observers, may have 
* complete information and will be able to identify the outcome, so we will be able to determine whether any statement about the outcome is true of false. For example, we will be able to tell whether first roll is $6$. Here every statement is an event. 
* partial information on the outcome. For example, we are only told what the sum was, so with the exception of a number of outcomes (how many?) - cannot determine if the statement "first roll is a $6$" is true or false. Therefore such a statement is not part of the information we have. Another example: "the two dice landed the same number", and there are many other. We gave two examples of statements which are not events. What are the events then: any statement on the sum is an event, because the sum is exactly the information we are given. Even the statement "the sum is $\pi$" is an event (we don't event have to wait for the outcome to determine its truth value though...). 
3. **[The probability measure](#Probability Measures)**. Probability measure is a function assigning a numerical value between $0$ and $1$ to every event, representing the "weight" of this event. The weight assigned to each event is also known as the probability of the event. This function must satisfy some rules, but very loosely generalizes the idea of proportion (what proportion of the sample space the event occupies), and in many cases - but not always - coincides with proportions, like in real life some objects "weigh" or are "more typical" than other. Note that with the exception of trivialities, there are many different probability measures for the same sigma-algebra, and therefore saying that the probability of event $A$ is $p$ is - with a few exceptions - model specific. We choose what probability measure to use. To understand this better, think again of the dice rolling example, and assume we have complete information. 
* The most intuitive setup is where we weigh each event proportionally to the number of corresponding outcomes. To make this clearer, recall first that we have a total of $36$ elements in the sample space. The event "sum is $6$", corresponds to the five outcomes $\\{(1,5),(2,4),(3,3),(4,2),(5,1)\\}$, and will be assigned probability of $5/36$. Similarly, the event "the two dice landed the same number" corresponds to six outcomes and will be assigned probability of $1/6$. 
* Suppose that there's some magnet under the table causing both dice to land $6$ every time. A choice of probability measure that will be faithful to this setup is to assign every statement in which at least one of the dice is not a $6$ a weight or probability $0$, and assign all remaining statements probability $1$. For example, the statement "sum is $6$" will be assigned probability $0$ and the statement "the two landed the same number" will be assigned probability $1$ (this always happens!). 
  : We just described two distinct probability measures for the same sample space, with the same information available to us (there are many, many more). The choice of which to use was based on the sampling, trying to be faithful to the mechanism. We will discuss how to choose the right probability measure when we talk about the Law of Large Numbers. Until then, we will be always provided with a probability measure, so don't get stressed about that, yet. 

Before the real misery begins, let's enjoy a fun video. Try to think of the concepts we just discussed as you watch it.
<youtube>https://www.youtube.com/watch?v=Kgudt4PXs28</youtube>

# Sample Spaces
Remember we are observers of an experiment? In probability theory, a **sample space** is the set of all outcomes in the experiment. Why "sample"? This is because we can turn the experiment around and consider it as some mechanism (usually not fully understood to us - can you tell exactly what happens when you toss a coin?) for "sampling" an element from that set of all possible outcomes, the sample space. We usually denote a sample space by the Greek letter Omega, $\Omega$, and we usually use $\omega$ to denote an element in the sample space. Let's introduce a number of examples. 

* I'm tossing a coin. The possible outcomes are Heads and Tails, which we will write as $H$ and $T$ respectively. Then $\Omega= \\{H,T\\}$. 
* I'm tossing three coins (or tossing a coin three times in a row). Then each outcome is a sequence of length $3$ consisting of $H$ and/or $T$, representing the outcome of the first, second and third toss respectively. In this case $\Omega = \\{H,T\\}^3 = \\{HHH,HHT,HTH,THH,HTT,THT,TTH,TTT\\}$, a [product set](combinatorics#product_rule). In many cases our experiment will involve repeating some smaller experiment several (or maybe even infinitely many) times, and this is where product sets come handy.
* I'm recording the price of a stock of Google at the end of the next trading day. We will assume the prices form a continuum. The sample space is all nonnegative numbers, $\Omega = [0,\infty)$. 

Mathematically, a sample space is nothing but a nonempty set. 

The following example describes what is perhaps the most important sample space in all of probability: 

\begin{xmpl}\tlabel{1}
The coin is tossed repeatedly indefinitely. Then the sample space $\Omega$ is the infinite product of the set ${\cal S}= \\{H,T\\}$, denoted by $\Omega= {\cal S}^{\N}$, that is, all infinite sequences of H's and T's. An $\omega$ in this sample space is an infinite sequence $\omega = (\omega_1,\omega_2,\dots)$, where $\omega_i \in {\cal S}=\\{H,T\\}$. 

Here's the beginning of an element $\omega$ in this sample space: $HHHTHTTTTTTHHHHH$, etc.  Here $\omega_1 = \omega_2=\omega_3 = H, \omega_4 =T,\dots $, representing Heads followed by three more Heads, then a Tails, Heads, no less than $6$ more Tails, etc... 
\end{xmpl} 

# Events and sigma-algebras
## Warm up
As already mentioned, depending on the details, we, the observers of the sampling, may have full or partial information on the outcome. Here we will describe what we mean by "information". 

What is knowledge? Ability to answer questions. One can summarize all our information about the outcome as all yes/no questions we will be able to answer for any possible outcome. 

Consider the following scenario. Three coins are tossed. The sample space is $\Omega= \\{H,T\\}^3$. During the tossing we were blindfolded, and the blindfold was removed at the conclusion of the tossing. The information available to us is therefore the number of Heads (or Tails), but not the order. We can answer all of the following questions about the outcome:

1. Are all tosses $T$? 
2. Is there exactly one $H$? 
3. Are there exactly two $H$? 
4. Are there exactly three $H$? 

Furthermore, the answers to all these questions (any three are enough, right?), determine everything we know about the outcome: the number of Heads. There are more questions we can answer: "is the number of $H$ even?" "are there more $T$ than $H$?", etc... On the other hand, the question "was the first toss $H$?" is one we cannot always answer. Of course, if we see $3$ $H$ or $3$ $T$, we can answer it, but we cannot answer it for any of the $6$ remaining outcomes. This is an example of a question we cannot *always* answer, and will be removed from our bank of questions. 

The point we're trying to make here is that "information" is synonymous with what yes/no questions we can answer. A long list of questions does not render as a good candidate for a mathematical object. However, everything one can learn from a question is captured in the answers to it. Particularly for a yes/no question on the outcome, an element in the sample space, all that information is captured in the subset of outcomes corresponding to a "yes" answer (all the remaining automatically correspond to a "no" answer). Therefore one can identify the question with the set of outcomes corresponding to a "yes" answer. The question "is the number of $H$ odd?" which is one we can answer, corresponds to the subset $\\{HTT,THT,TTH,HHH\\}$. The question "is the number of $T$ equal to $3.14$?" corresponds to the subset $\emptyset$, the empty set, etc. 

Therefore, each question we can always answer will be replaced by a subset of $\Omega$, representing all outcomes corresponding to a "yes" answer. Each such subset is called an **event** and the collection of all events in called a **sigma-algebra** or $\sigma$-algebra. An event can be also identified with a statement about the outcome: the statement whose veracity the corresponding question aims to determine. The event $\\{HTT,THT,TTH,HHH\\}$ corresponds to the statement "the number of $H$ is odd" (or "number of $H$ is $1$ or $3$" or "number of $T$ is even") and the event $\\{HHH\\}$ corresponds to the statement "all tosses are $H$" (or "no $T$"). The event $\emptyset$ corresponds to any statement which is always false, like "number of $H$ is $-1$" or "stocking on toilet paper is an act of rationality". 

## Definition and first properties
In the last section we saw that the seemingly ambiguous notion of "information" can be made quite precise as the collection of subsets of the sample space, each representing all outcomes corresponding to a "yes" answer to a question we, the observers of the experiment, can answer always answer. 
pro
We observe that any such collection satisfies the following properties: 
1. $\Omega$ is always an event, corresponding to the question "the the outcome in $\omega$?
2. Suppose $A$ is an event. If we negate the corresponding question, this we get a new question we can also answer, and the set of outcomes corresponding to a "yes" answer to the new question is exactly $A^c$. Therefore $A^c$ is an event. 
3. <a id="union"></a> Suppose $A$ and $B$ are events. We can therefore answer "is outcome in $A$?" and "is outcome in $B$?". Therefore we can answer "is outcome in $A$ or in $B$?" and as the set of outcomes corresponding to "yes" for the latter question is the union $A\cup B$, we conclude that $A\cup B$ is an event. 
  : By iterating, the union of any finite number of events is an event. 

A collection of subsets of $\Omega$ satisfying the three properties above is called an **algebra** of sets on $\Omega$. Reverse-engineering, we will use these properties as the basis for our mathematical definition of "information". I said "basis" because there's going to be one change associated with infinite unions, as - similarly to real life - some structure can be only viewed from birds' eye, from space, from infinity... and beyond: 

\begin{defn}\tlabel{sigma_algebra}
Let $\Omega$ be a sample space. A sigma-algebra (or $\sigma$-algebra) on $\Omega$ is a set ${\cal F}$ whose elements are subsets of $\Omega$, and which satisfies all of the following: 
1. $\Omega \in {\cal F}$ (not empty)
2. If $A\in {\cal F}$ then $A^c \in{\cal F}$ (closed under complements) 
3. If $A_1,A_2,\dots \in{\cal F}$ then $\cup_{i}A_i\in {\cal F}$ (closed under countable unions)
\end{defn}
Any sigma-algebra is an algebra. Indeed, if ${\cal F}$ is a sigma-algebra, then $\Omega\in {\cal F}$ and therefore its complement, $\emptyset \in {\cal F}$. Now suppose $A_1,A_2\in {\cal F}$. Then letting $A_3=A_4=\dots =\emptyset$, we have $A_1 \cup A_3 = \cup_{i=1}^\infty A_i \in {\cal F}$. 

With this definition, we have a new tool. The information about the outcome of the experiment will be always expressed as a corresponding sigma-algebra. Now for concrete sigma-algebras. We begin with two extreme cases. 

1. No information at all. The only questions we can answer are those which have only one answer: either always "yes" or always "no". Therefore the sigma-algebra consists of exactly two sets: $\Omega$ and $\emptyset$. WE can write this as ${\cal F} = \\\{\emptyset,\Omega\\}$. For trivial reasons, this is known as the **trivial sigma-algebra**. 

1. We have all information about the outcome. We can answer any question: if $A$ is any subset of $\Omega$, we can answer the question "is the outcome in $A$?". Therefore every subset of $\Omega$ is in the sigma-algebra.Therefore every subset of $\Omega$ is in the sigma-algebra. This sigma-algebra, the set of all subsets of $\Omega$ is called the **power set** of $\Omega$ and will be denoted by ${\mathcal P}(\Omega)$. If $\Omega$ is finite, its power set always has $2^{\|\Omega\|}$  elements. Can you think why?

I want to pause here for a few seconds and make sure we're all on the same page, regarding the 
\begin{xmpl}\tlabel{3}
Suppose we toss a coin and can see the outcome. What is the sample space and sigma-algebra? 
Clearly, $\Omega = \\{H,T\\}$. Since we have all information, ${\cal F}= {\cal P}(\Omega) = \\{\emptyset, \\{H\\},\\{T\\},\\{H,T\\}\\}$. 
\end{xmpl}
\begin{exer}\tlabel{5}
Show that the definition implies that a sigma-algebra is closed under finite unions (enough to prove for two). That is, if ${\cal F}$ is a sigma-algebra and $A,B\in {\cal F}$, then $A\cup B\in{\cal F}$. 
\end{exer} 

When $\Omega$ has more than one element, there are other sigma-algebras than the trivial and the power set. Here's an example. 

\begin{xmpl}\tlabel{two_coins_sigma_algebra}
Two coins are tossed in a row. The sample space is $\Omega =\\{H,T\\}^2$. In each of the following cases determine the sigma-algebra. 
1. You were blindfolded during the tossing with blindfold removed after tossing is complete. 
  : Clearly $\emptyset$ and $\Omega$ are events. 
  : Then any subset corresponding to a fixed number of $H$: $\\{TT\\},\\{TH,HT\\},\\{HH\\}$. 
  : Add unions of any of the above: $\\{TT,TH,HT\\},\\{TT,HH\\},\\{TH,HT,HH\\}$. 
  : Now look and see that the collection thus obtained consists of $8$ sets and is closed under complements and unions. Therefore 
  : $${\cal F} = \\{\emptyset, \\{TT\\},\\{TH,HT\\},\\{HH\\}, \\{TT,TH,HT\\},\\{TT,HH\\},\\{TH,HT,HH\\}, \Omega\\}.$$ 
2. You were only told whether there is a $H$ or not. 
  : Clearly, $\emptyset$ and $\Omega$ are events. 
  : The subsets corresponding to zero $H$ or at least one $H$: $\\{TT\\},\\{HT,TH,HH\\}$. 
  : The four sets lists above are closed under complements and unions. Therefore
$${\cal F} = \\{\emptyset, \\{TT\\},\\{HT,TH,HH\\},\Omega\\}.$$ 
\end{xmpl} 

\begin{exer}\tlabel{coin}
I'm tossing a coin three times. I'm telling you the outcome of the first toss and the number of remaining tosses with the same outcome. 
Give: 
1. Two examples of non-trivial (not empty and not entire sample space) sets which from your perspective are events, in words (e.g. "first toss is Heads" - don't use this one!) 
2. Two examples of sets which from your perspective are not events, in words. 
\end{exer} 

\begin{exer}\tlabel{remainder}
You are rolling a $6$-sided die. You're telling me what is the remainder of the outcome when divided by $3$. List all elements in the sigma-algebra. 
\end{exer} 

We required sigma-algebras to be closed under countable unions. What about intersections? If we look back at the [argument that lead to closure under finite unions](#union), then we can guess that algebras and sigma-algebras are also closed under countable intersections. To see why, this follows from the definition we just presented, recall two important identities about sets widely known as [De Morgan's laws](Wikipedia:De_Morgan%27s_laws): 

\begin{empheq}\label{demorgan}
(\bigcap A_i)^c= \bigcup A_i^c.
\end{empheq}

On rewriting this (how?) and using the fact that $(A^c)^c=A$ for any set $A$, we obtain
  
\begin{empheq}\label{demorgan2}
(\bigcup A_i)^c = \bigcap A_i^c.
\end{empheq}

We comment that \eqref{demorgan} and \eqref{demorgan2} hold regardless whether we are considering finitely many indices $i$ or not. 

Why now? Because De Morgan's laws give the following property:
 
\begin{prop}\tlabel{intersect}
If ${\cal F}$ is a sigma-algebra on $\Omega$ and $A_1,A_2,\dots \in {\cal F}$, then $\cap_i A_i \in {\cal F}$.
\end{prop}

\begin{exer}\tlabel{6}
Prove \ref{intersect}. 
\end{exer}

In words, sigma-algebras are closed under countable intersections. Of course, they are also closed under finite intersections, as $\Omega$ is an element in any sigma-algebra. Simply put: if you have any (finite or countable) number of events, then what obtained by taking unions, complements, intersections of any of them is an event. Of course you can iterate that. The only way to "split" an event is by intersecting it with another event. The only way to "enlarge" an event is by taking its union with another event. 

Let's take a quick pause and make sure we understand the relation between the mathematical operations of union, intersection and complements and words. This is something many find confusing. Remember this:"
* "Event A and event B" or any other way to say it in words (e.g. "Both events A and B") is the intersection of $A$ and $B$, $A\cap B$, with the immediate generalization for more than just two. 
  : "and" means "all" means intersection. 
* "Event A or event B" or any other way to say it, most commonly "at least one of the Events A and B", corresponds to the union of $A$ and $B$, $A\cup B$
  : "or" means "at least one" means union. 
Here is a more verbal example. 

\begin{xmpl}\tlabel{union_sect_comp}
I'm playing $10$ soccer games. For $i=1,\dots,10$, let $A_i$ be the event "I won the $i$-th time". 
1. The statement "I lost win game $i$" is the same as "I did not win game $i$", the complement of $A_i$, $A_i^c$.
2. The statement "I won at least one game" is the same as "I won game 1 or game 2 or game 3 ... or game 10". This is the union $\cup_{i=1}^{10} A_i$. Union of events is the same as "at least one of the events". 
3. The statement "I lost all games" is the complement of the statement in the last bullet item, the union $\cup_{i=1}^{10} A_i$. It also means "I lost game 1 and game 2 and ... and game 10". That is, it is the intersection $\cap_{i=1}^{10} A_i^c$. In other words (or without words, actually), $(\cup_{i=1}^{10} A_i)^c= (\cap_{i=1}^{10} A_i^c)$. This is \eqref{demorgan2} in action. 
4. The statement "I won all games" is, of course, the intersection $\cap_{i=1}^{10} A_i$. Its complement is "I lost at least one game", which is the same as "I lost game 1 or game 2 or ... or game 10". This is the union $\cup_{i=1}^{10} A_i^c$. Thus, $(\cap_{i=1}^{10} A_i)^c = \cup_{i=1}^{10} A_i^c$, and this is \eqref{demorgan} in action. 
5. The statement "I lost the first 5 games and won at least one in the last 5" is the intersection of the following two: 
  : "I lost game 1 and game 2 .... and ... game 5 ", $\cap_{i=1}^5 A_i^c$; and 
  : "I won game 6 or game 7 or ... or ... game 10", $\cup_{i=6}^{10} A_i$. 
  : Therefore we can write it as $\left(\cap_{i=1}^5 A_i^c\right)\cap \left(\cup_{i=6}^{10} A_i\right)$. 
6. The complement of the statement in the last item will be obtained by repeatedly applying DeMorgan's laws. 
  : Set $A=\left(\cap_{i=1}^5 A_i^c\right)$ and $B=\left(\cup_{i=6}^{10} A_i\right)$. Then the statement in the last item is $A\cap B$. 
  \end{xmpl}

<a id="Probability Measures"></a>
# Probability Measures
Suppose we fixed a sample space $\Omega$ and a sigma-algebra ${\cal F}$. A **probability measure** is a function $P$ whose domain is the sigma-algebra ${\cal F}$, and whose image is the interval $[0,1]$, $P:{\cal F}\to [0,1]$. This function satisfies two important properties: 
1. $P(\Omega) = 1$ (normality)
2. If $A_1,A_2,\dots$ is a sequence of *disjoint* events in ${\cal F}$ (i.e. $A_i \cap A_j = \emptyset$ for $i\ne j$), then $P(\cup_{i=1}^\infty A_i) = \sum_{i=1}^\infty P(A_i)$ (countable additivity) 

The triplet $(\Omega,{\cal F},P)$ is called a **probability space**. When we say "the probability of event $A$ is $p$" we mean $P(A)=p$. The rules we set up in the definition guarantee many important properties. 

\begin{prop}\tlabel{prob_prop}
Let $(\Omega,{\cal F},P)$ be a probability space. Then: 
1. $P(\emptyset)=0$. 
2. If $A,B\in {\cal F}$ are disjoint, then $P(A\cup B) = P(A)+P(B)$ (finite additivity).
3. For any $A\in {\cal F}$, $P(A^c)=1-P(A)$. 
4. If $A,B\in {\cal F}$ and $A\subseteq B$, then $P(A)\le P(B)$ (monotonicity). 
5. For any $A,B\in {\cal F}$, $P(A\cup B) = P(A)+P(B)-P(A\cap B)$. 
\end{prop}

\begin{pf}\tlabel{prop_prop_pf}
1. Since $\Omega = \Omega \cup \emptyset \cup \emptyset \cup \dots$ is a countable union of disjoint sets, by countable additivity, 
$$1 = P(\Omega) = P(\Omega) + P(\emptyset) + P(\emptyset) + \dots$$
Subtracting $P(\Omega)$ from both sides we get $0 = P(\emptyset) + P(\emptyset) + \dots$. Since $P(\emptyset)$ is a nonnegative number and the sum of nonnegative numbers is zero, we must have $P(\emptyset)=0$. 
2. Let $A_1=A, A_2=B$ and $A_3=A_4=\dots =\emptyset$. These are disjoint events, and $\cup_{i=1}^\infty A_i = A\cup B$. By countable additivity: 
$$P(A\cup B) = P(A_1)+P(A_2) + \sum_{i=3}^\infty P(A_i) = P(A)+P(B) + \sum_{i=3}^\infty P(\emptyset) = P(A)+P(B).$$
3. Since $A$ and $A^c$ are disjoint and $A\cup A^c = \Omega$, by finite additivity and normality we have 
$$P(A)+P(A^c) = P(A\cup A^c) = P(\Omega) = 1,$$
from which $P(A^c) = 1-P(A)$. 
4. If $A\subseteq B$, then $B=A\cup (B\setminus A)$. Since $A$ and $B\setminus A$ are disjoint events (and since $\Omega \in {\cal F}, B\in {\cal F}$, then $B\setminus A = B\cap A^c$ is an event too), we have
$$P(B) = P(A)+P(B\setminus A).$$
Since $P(B\setminus A)\ge 0$ as $P$ is a probability measure, $P(B) \ge P(A)$. 
5. The set $A\cup B$ can be decomposed into disjoint events as: 
$$A\cup B = A\cup (B\setminus A).$$ 
From finite additivity we have $P(A\cup B) = P(A)+P(B\setminus A)$. Now the set $B$ can be decomposed into disjoint events as: 
$$B=(B\setminus A)\cup (A\cap B).$$
From finite additivity we have $P(B) = P(B\setminus A)+P(A\cap B)$, and therefore $P(B\setminus A) = P(B)-P(A\cap B)$. Substituting this into the first equality gives the result. 
\end{pf} 

<a id="prob_prop_an"><a>
The last property is known as **inclusion-exclusion principle**, and can be generalized to three or more events. For three events $A,B,C$ it is: 
$$P(A\cup B\cup C) = P(A)+P(B)+P(C)-P(A\cap B) - P(A\cap C) - P(B\cap C) + P(A\cap B\cap C).$$ 
 
\begin{exer}\tlabel{prob_prop_general}
Prove that for any sequence of events $A_1,A_2,\dots \in {\cal F}$, $P(\cup_i A_i) \le \sum_i P(A_i)$ (known as the **union bound**). 
\end{exer} 
## Discrete probability spaces
The mathematical setup becomes much simpler when the sample space is finite or countably infinite (i.e. the outcomes can be enumerated). If $\Omega$ is a finite or countable set, we will always set the sigma-algebra to be the power set, ${\cal F}={\cal P}(\Omega)$. 

Since the sigma-algebra is the power set, every subset of $\Omega$ is an event. The probability measure must therefore assign a probability to every subset of $\Omega$. By countable additivity, the entire measure is determined by the probabilities assigned to the **singleton** events $\\{\omega\\}$, where $\omega\in \Omega$. Specifically, if $A$ is any event, then $A= \cup_{\omega\in A} \\{\omega\\}$ is a (finite or countable) union of disjoint events, and therefore 
$$P(A) = \sum_{\omega\in A} P(\\{\omega\\}).$$
Let's use a shorthand notation $p_\omega = P(\\{\omega\\})$. Then $p_\omega\ge 0$ for all $\omega\in \Omega$, and from normality, 
$$1= P(\Omega) = \sum_{\omega\in \Omega} p_\omega.$$ 
In other words, in a discrete probability space, the entire probability measure is determined by a function $p:\Omega\to [0,1]$ such that $\sum_{\omega\in \Omega} p_\omega = 1$. The function $p$ is known as a **probability mass function** or **PMF**. 

\begin{xmpl}\tlabel{PMF_dice}
Consider the two dice experiment. $\Omega=\\{1,\dots,6\\}^2$. In the absence of any information to the contrary, we will always use the **uniform probability measure** which assigns $p_\omega = 1/36$ for all $\omega\in \Omega$. 

The event $A=\text{"sum is } 6\text{"}$ is $A = \\{(1,5),(2,4),(3,3),(4,2),(5,1)\\}$, and since $\|A\|=5$, $P(A) = 5\cdot 1/36 = 5/36$. 

The event $B=\text{"at least one of the dice is } 6\text{"}$ is $B=\\{(i,j): i=6 \text{ or } j=6\\}$. $\|B\|=11$, so $P(B)=11/36$. 
\end{xmpl}

\begin{exer}\tlabel{PMF_dice2}
For the two dice example: 
1. Calculate the probability of the event $C=\text{"first roll is a } 6\text{"}$. 
2. Calculate the probability of the event $D=\text{"the two dice landed the same number"}$. 
3. Calculate the probability of the event $C\cup D$. 
\end{exer}

## Continuous probability spaces
Probability spaces for which the sample space $\Omega$ is an uncountably infinite set (most commonly $\R$ or a subset of $\R$) are known as **continuous probability spaces**. In a continuous probability space, the power set ${\cal P}(\Omega)$ is too large, and in most cases no probability measure exists on it (except for the trivial measure, $P(A)=0$ for all $A$). We therefore must choose a sigma-algebra which is a strict subset of ${\cal P}(\Omega)$. 

The most common sigma-algebra for continuous probability spaces is the **Borel sigma-algebra** (or Borel sets). On the real line $\R$, the Borel sigma-algebra, denoted by ${\cal B}(\R)$ is the smallest sigma-algebra containing all open intervals $(a,b)$. Since a sigma-algebra is closed under complements, ${\cal B}(\R)$ must also contain all closed intervals $[a,b]$, open/closed intervals $(a,b]$ and $[a,b)$, and all finite and countable unions/intersections of all of these sets. All common sets (points, intervals, finite unions of intervals, etc.) are in ${\cal B}(\R)$. 

Just as in the discrete case, the entire probability measure is determined by the "weight" assigned to the smallest elements. The smallest elements of ${\cal B}(\R)$ are the open intervals $(a,b)$. The probability measure is therefore usually defined by specifying a function $F:\R\to [0,1]$ which satisfies $P((-\infty,x])=F(x)$. Such a function is called a **cumulative distribution function** (or **CDF**). This can be used to calculate the probability of any event. For example: 
$$P((a,b]) = P((-\infty,b]\setminus (-\infty,a]) = P((-\infty,b]) - P((-\infty,a]) = F(b)-F(a).$$
If $F$ is a differentiable function, then the probability measure is defined via the **probability density function** (or **PDF**), $f(x)=F'(x)$ for which 
$$P(A) = \int_A f(x)dx.$$

\begin{xmpl}\tlabel{uniform_cont}
**The uniform distribution on $[0,1]$**. The sample space is $\Omega=[0,1]$. The CDF is 

$$F(x) = \begin{cases} 0 & x<0 \\ x & 0\le x\le 1 \\ 1 & x>1, \end{cases}$$

and the PDF is 

$$f(x) = \begin{cases} 1 & 0\le x\le 1 \\ 0 & \text{otherwise}. \end{cases}$$

For any $A\subseteq [0,1]$, $P(A)$ is exactly the [Lebesgue measure](Wikipedia:Lebesgue_measure) (length) of $A$. 

1. $P([0.1, 0.5]) = 0.5-0.1 = 0.4$. 
2. $P(\\{0.5\\}) = 0$ (probability of any single point is zero). 
3. $P(\text{outcome is rational}) = 0$ (the set of rational numbers has Lebesgue measure zero). 
\end{xmpl}

## The sigma-algebra generated by a set of events
We say that a sigma-algebra ${\cal F}$ is **generated** by a collection of subsets $\cal C$ if ${\cal F}$ is the smallest sigma-algebra containing $\cal C$. The notation for this is ${\cal F} = \sigma({\cal C})$. The Borel sigma-algebra ${\cal B}(\R)$, for example, is generated by the collection of all open intervals: ${\cal B}(\R) = \sigma(\\{(a,b): a,b\in \R\\})$. 

\begin{exer}\tlabel{Borel_sets}
Show that ${\cal B}(\R)$ is also generated by the collection of all open intervals of the form $(-\infty, a)$, that is, ${\cal B}(\R) = \sigma(\\{(-\infty,a): a\in \R\\})$. 
\end{exer} 
\begin{prop}\tlabel{finite_sigma}
If $\Omega$ is a **finite set**, and ${\cal C} = \\{ \omega : \omega \in \Omega \\}$ is the collection of all singletons, then $\sigma({\cal C}) = {\cal P}(\Omega)$, the power set. 
\end{prop}

\begin{pf}\tlabel{finite_sigma_pf}
Let $A\subseteq \Omega$ be any set. Since $A = \cup_{\omega\in A} \\{\omega\\}$ is a finite union of sets in ${\cal C}$, and since $\sigma({\cal C})$ must be closed under finite unions, $A\in \sigma({\cal C})$. Thus ${\cal P}(\Omega)\subseteq \sigma({\cal C})$. Since $\sigma({\cal C})$ is a sigma-algebra, it is a collection of subsets of $\Omega$, so $\sigma({\cal C})\subseteq {\cal P}(\Omega)$. The two inclusions imply $\sigma({\cal C}) = {\cal P}(\Omega)$. 
\end{pf}

\begin{prop}\tlabel{pi_lambda}
The **$\pi$-$\lambda$ theorem** is a fundamental result in measure theory which is of limited utility to an introductory probability class, but whose importance for those continuing in the field is immense. The theorem states: If $\cal P$ is a $\pi$-system and $\cal L$ is a $\lambda$-system, and $\mathcal{P} \subseteq \mathcal{L}$, then $\sigma(\mathcal{P}) \subseteq \mathcal{L}$. 
\end{prop}

<a id="Probability Spaces-Probabilities on infinite sample spaces"></a>
# Probabilities on infinite sample spaces

The main problem with probability spaces on infinite sample spaces is that the power set is too large, and in the case of uncountable $\Omega$ no probability measure exists on it. The following lemma provides a mathematical framework for this. 

\begin{lem}\tlabel{countable_singletons}
In any continuous probability space $(\Omega,{\cal F},P)$ there is an uncountably infinite number of singletons $\\{\omega\\}$ that are not events, i.e., $\\{\omega\\}\notin {\cal F}$. 
\end{lem}

\begin{prop}\tlabel{finite_sigma}
If $\Omega$ is a **finite set**, and ${\cal C} = \\{\omega\\}$ is the collection of all singletons, then $\sigma({\cal C}) = {\cal P}(\Omega)$, the power set. 
\end{prop}

\begin{pf}\tlabel{finite_sigma_pf}
Let $A\subseteq \Omega$ be any set. Since $A = \cup_{\omega\in A} \\{\omega\\}$ is a finite union of sets in ${\cal C}$, and since $\sigma({\cal C})$ must be closed under finite unions, $A\in \sigma({\cal C})$. Thus ${\cal P}(\Omega)\subseteq \sigma({\cal C})$. Since $\sigma({\cal C})$ is a sigma-algebra, it is a collection of subsets of $\Omega$, so $\sigma({\cal C})\subseteq {\cal P}(\Omega)$. The two inclusions imply $\sigma({\cal C}) = {\cal P}(\Omega)$. 
\end{pf}

\begin{prop}\tlabel{pi_lambda}
The **$\pi$-$\lambda$ theorem** is a fundamental result in measure theory which is of limited utility to an introductory probability class, but whose importance for those continuing in the field is immense. The theorem states: If $\cal P$ is a $\pi$-system and $\cal L$ is a $\lambda$-system, and $\mathcal{P} \subseteq \mathcal{L}$, then $\sigma(\mathcal{P}) \subseteq \mathcal{L}$. 
\end{prop}

<a id="Probability Spaces-Probabilities on infinite sample spaces"></a>
# Probabilities on infinite sample spaces

The main problem with probability spaces on infinite sample spaces is that the power set is too large, and in the case of uncountable $\Omega$ no probability measure exists on it. The following lemma provides a mathematical framework for this. 

\begin{lem}\tlabel{countable_singletons}
In any continuous probability space $(\Omega,{\cal F},P)$ there is an uncountably infinite number of singletons $\\{\omega\\}$ that are not events, i.e., $\\{\omega\\}\notin {\cal F}$. 
\end{lem}

\begin{pf}\tlabel{countable_singletons_pf}
Suppose to the contrary that there's an uncountably infinite number of singletons that are events. Then the collection of these singletons is an uncountable collection of disjoint events, ${\cal C} = \\{ \\{\omega\\}\:\\{\omega\\}\in {\cal F}\\}$ with $\|{\cal C}\|>\aleph_0$.  By countable additivity, we must have 
$$\sum_{\\{\omega\\}\in {\mathcal C}} P(\\{\omega\\}) \le P(\Omega) = 1.$$
Since the sum converges and each $P(\\{\omega\\})\ge 0$, at most a countable number of terms can be positive. Therefore, there is an uncountable number of singletons in ${\cal C}$ with $P(\\{\omega\\})=0$. Let $A_n = \\{\omega\in \Omega: P(\\{\omega\\})>1/n\\}$. Then $\cup_n A_n$ is a countable union of countable sets, so it is countable, but it is an uncountable subset of $\Omega$. Thus, there is an uncountably infinite number of singletons which are not events. 
\end{pf}

# Problems
\begin{prob}\tlabel{complement_diff}
Suppose that $A,B\in {\cal F}$. Show that the following are events: 
1. $A \setminus B$. 
2. The symmetric difference $A\Delta B$. 
\end{prob}

\begin{prob}\tlabel{prob_cont}
Let $(\Omega,{\cal F},P)$ be a continuous probability space. Show that for every $\omega\in \Omega$, $P(\\{\omega\\}) = 0$. 
\end{prob}

\begin{prob}\tlabel{disjoint_union}
Let $A_1,A_2,\dots \in {\cal F}$ be a sequence of events. Let $B_1=A_1$ and for $n\ge 2$, $B_n = A_n \setminus (A_1\cup \dots \cup A_{n-1})$. Show that $B_n$ are disjoint events and $\cup_{n=1}^\infty A_n = \cup_{n=1}^\infty B_n$. 
\end{prob}

\begin{prob}\tlabel{prob_cont_countable}
Let $(\Omega,{\cal F},P)$ be a probability space. Suppose $A_1,A_2,\dots \in {\cal F}$ is a sequence of events. Show that $P(\cup_{n=1}^\infty A_n) = \lim_{n\to \infty} P(\cup_{k=1}^n A_k)$. 
\end{prob}

\begin{prob}\tlabel{lim_sup_inf}
Let $A_1,A_2,\dots \in {\cal F}$ be a sequence of events. Show that $\limsup A_n$ and $\liminf A_n$ are events. 
\end{prob}

\begin{prob}\tlabel{finite_to_countable}
Let $(\Omega,{\cal F},P)$ be a probability space where $\Omega$ is finite. Show that countable additivity is equivalent to finite additivity. 
\end{prob}

\begin{prob}\tlabel{sigma_algebra_generated}
Let $\Omega=\\{1,2,3,4\\}$ and $\mathcal{C}=\\{ \\{1,2\\} , \\{2,3\\} \\}$. Find the sigma-algebra generated by $\mathcal{C}$, $\sigma(\mathcal{C})$. 
\end{prob}

\begin{prob}\tlabel{sigma_algebra_generated2}
Let $\Omega=\\{ 1,2,3,4,5,6 \\}$ and $\mathcal{C}=\\{ \\{1,2,3\\} , \\{3,4,5\\} \\}$. Find the sigma-algebra generated by $\mathcal{C}$. 
\end{prob}

\begin{prob}\tlabel{prob_intersection}
A committee of 5 people is selected randomly from a group of 10 men and 10 women. What is the probability that the committee consists of exactly 3 men and 2 women? 
\end{prob}

\begin{prob}\tlabel{prob_cards}
A hand of 5 cards is dealt from a standard deck of 52 cards. 
1. What is the probability that the hand is a flush (all 5 cards of the same suit)? 
2. What is the probability that the hand contains exactly one pair (two cards of the same rank and three other cards of different ranks)? 
\end{prob}

\begin{prob}\tlabel{prob_cards2}
Consider a permutation of the numbers $1, 2, \dots, n$. Let $A_i$ be the event that the number $i$ is in the $i$-th position (a fixed point). 
1. Calculate $P(A_i)$ and $P(A_i \cap A_j)$ for $i \ne j$. 
2. Use the inclusion-exclusion principle to find the probability of the event that *at least one* number is in its original position. 
\end{prob}

\begin{prob}\tlabel{prob_cards3}
You are given a deck of $n$ cards, numbered $1$ to $n$. You deal them in a random sequence. Find the probability that there is an increasing sequence of three cards. 
\end{prob}

\begin{prob}\tlabel{politics}
A lesson about politics ? 
 
Three political candidates. 
* One, an extremely solid candidate with a fixed base of support will get between $21\%$ and $24\%$ of the votes.
* Second, also relatively solid, gets $20\%$ of the votes or $30\%$, depending on the day (according to whether it's a rainy day or not), each with probability $1/2$.
* Third, a firebrand, will get below $5\%$ or between $32\%$ and $38\%$ (according to whether saying something controversial or makes promises on the economy), with probability $1/2$ each, independently of the second. 

1. Suppose that exactly two of the candidates compete in the election. For each possible pair, what is the probability for each candidate to win?
2. Now suppose all three compete. What is the probability for each candidate to win? 
\end{prob}

\begin{prob}\tlabel{toss_inf}
Suppose that our experiment involves repeatedly tossing a coin. The sample space is all infinite sequences formed by Heads and Tails. Suppose that for every $n$, the set  ``n-th toss is Heads`` is an event. Show that all of the following are also events: 

1. "Heads will appear infinitely many times"
2. "The proportion of Heads among the first $n$ tosses will exceed $2/3$ only finitely many times". 
3. "For every $n$, there will be a run (consecutive sequence) of Heads of length larger than $n$" 
\end{prob}

<!-- Mandatory TOC -->
* TOC
{:toc}