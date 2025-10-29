---
title: Transformations
layout: latex
---

# Intro
If $X$ is a RV and $g:\R to \R$ is a nice function then we can define a new RV  $Y$ by letting $Y = g(X)$. Then this $Y$ is a *transformation* of $X$, a synonym for a ``function of $X$*. That's it. Let's look at an example.

The radius of a round tumor grows at a rate of $1\%$ per day until detected. On day $0$, the radius of the tumor is $1/10$ of an inch. Suppose that the number of days until the tumor is detected is random variable $T$ with some known distribution.

The radius of the tumor on the day it is detected is $0.1 * (1.01)^T$, a function of the RV $T$, and the area covered by the tumor that day is $\pi *(0.1 * (1.01)^T)^2$. Both quantities are RVs which are functions of $T$. These are examples of **transformations** of the RV $T$, nothing but a fancy name for a function of a RV.

In this section we discuss how to compute distribution and expectation of some easier classes of transformations of RVs. I'd like to emphasize the following:

1. Transformations of discrete RVs are always discrete RVs, while *any* distribution (discrete/continuous/mixed)  can be obtained as a transformation of a (any) continuous RV. See \ref{Theorem}.
1. Finding the distribution of transformations of RVs can be a bit tricky (not always!).
1. Formulas for calculating expectations of transformations is fairly straightforward, and do not require finding the distribution of the transformation.

This video illustrates the idea of a transformation of some random variable.  Can you identify which?
https://www.youtube.com/watch?v=ZFNstNKgEDI

In what follows we will limit the discussion to transformations of discrete and RVs with densities, and discuss each of the cases in a separate section.

# Transformations of Discrete RVs
Let's begin with the simplest case when $X$ is a discrete RV. Let's suppose that $g:\R \to \R$ is some function. Then $Y=g(X)$ is a discrete RV, because $X$ can only take countably many values, hence $Y$. We know then that
$$E [Y] = \sum_{y} y P(Y=y) = \sum_y y P(g(X) =y).$$
For each $y$,  $P(g(X)=y) = \sum_{x:g(x)=y} P(X=x)$, which gives us the PMF of $Y$. Plugging this into the definition of expectation, we obtain
$$ E[Y] = \sum_{y} \sum_{x:g(x)=y} y P(X=x)= \sum_y \sum_{x:g(x)=y} g(x) P(X=x).$$
The iterated summation guarantee summation over all $x$ in the support of $X$, each exactly once. We record the result.

\begin{prop}
Let $X$ be a discrete RV and let $g:\R\to \R$ be a function. Let $Y=g(X)$. Then
1. The PMF of $Y$ is given by
$$p_Y(y) = \sum_{x:g(x)=y} P(X=x).$$
1. The expectation of the  RV $g(X)$  is
$$E[g(X)] = \sum_x g(x) p_X(x),$$
provided $\sum_x |g(x)|p_X(x)$ is finite.
\end{prop}

What's important? We don't really need to calculate the PMF of the transformed RV.
\begin{xmpl}
\label{xmpl:binom_exp}
Let $X\sim\mbox{Bin}(n,p)$. We will show that
$$E[e^{t X} ] = (pe^t +(1-p))^n.$$
In our case $g(x) = e^{t x}$, so we need to figure out
\begin{align}
\label{eq:mom_gen}
E [ e^{t X} ] & = \sum_{x=0}^n e^{t x} P(X=x)\\
\nonumber
&  = \sum_{x=0}^n e^{t x} \binom{n}{x} p^x (1-p)^{n-x} \\
\nonumber
 & = \sum_{x=0}^n \binom{n}{x} (pe^t)^x (1-p)^{n-x}\\
 \nonumber
 & = (pe^t +(1-p))^n,
\end{align}
\end{xmpl}
where in the last equality, the [binomial formula](Combinatorics#prob:binom_thm) was used.

\begin{xmpl}
\label{xmpl:inf_exp}
A computer virus spreads at a rate of $25\%$ per day, and the number of days until it is stopped is Geometric with expectation of 5 days. What is the expected number of computers affected until it is stopped, if on day zero $4000$ computers were affected?

Let $T$ denote the number of days until the virus is stopped. Then $T\sim \mbox{Geom}(1/5)$. The number of computers affected is by the time the virus is stopped is $X=4000* 1.25^T$, a transformation of $T$. Note that $X$ is finite, because $T$ is finite. To compute the expectation of $X$ we write
$$ E[X] = \sum_{t\in\N} 4000*1.25^t P(T=t) = \sum_{t\in \N} 4000 *(\frac{5}{4})^t (\frac{4}{5})^{t-1} \frac 15 =\infty.$$
Therefore the expected number of computers affected is infinite, although the actual number is always finite.
\end{xmpl}

\begin{exer}
\label{exer:dis_trans}
Let $X$ be uniform RV on $\{1,2,3,4,5,6\}$ and let $Y=|X-3.5|$. What is the expectation of $Y$?
\end{exer}

\begin{exer}
What is the expectation of $X$ in \ref{xmpl:inf_exp} if the number of days until the virus is stopped is Geometric with expectation of 4 days?
\end{exer}



\begin{xmpl}
Suppose that $X$ is a discrete, integer valued RV.  What is the probability that $X$ is even?

We are going to solve this with transformations, using the following simple fact: for an integer $k$, $(-1)^k$ is $1$ if $k$ is even and $-1$ if $k$ is odd. Now
$$E[ (-1)^X ]=E[ {\bf 1}_{\{X\mbox{ even}\}} - {\bf 1}_{\{X \mbox{ odd}\}}] = 2 P(X\mbox{ even})-1.$$
In other words,
$$ P( X\mbox{ even}) = \frac 12 +\frac12 E[(-1)^X].$$
Let's compute this for two particular cases.

1. $X\sim \mbox{Bin}(n,p)$. Then
$$E[(-1)^x]=\sum_{k=0}^n \binom{n}{k} (-1)^k p^k (1-p)^{n-k} = (1-2p)^n,$$ where the last equality is due to the [binomial theorem](combinatorics#prob:binom_thm). Therefore,
$$ P(X \mbox{ even}) = 1/2+ 1/2(1-2p)^{n}.$$
1. $X \sim \mbox{Pois}(\lambda)$.
In this case
$$E[(-1)^X]=e^{-\lambda}  \sum_{k=0}^\infty (-1)^k \lambda^k /k! =e^{-2\lambda}.$$
Therefore
$$ P(X\mbox{ even})= \frac 12 + \frac 12 e^{-2\lambda}.$$
\end{xmpl}
<!--How about \video{\myweb\/Discrete_Transformations/Discrete_Transformations.html}{some more discrete transformations}?-->

# Transformations of Continuous RVs
It may be useful to review the [chain rule](https://Wikipedia:Chain_rule) and the [substitution formula for integrals](https://Wikipedia:Integration_by_substitution) from calculus.

It's worth beginning with a discussion on a common error. In an exam I gave several times I asked something like this:
- *Suppose $X\sim U[0,1]$ and let $Y=X^2$. Find the density of $Y$*.

The most common answer I received was something like this:

- * The density of $X$, $f_X$  is equal to  $1$ on $[0,1]$ and to zero elsewhere. The density of $Y=X^2$ is therefore equal to $(f_X(x))^2$, that is equal to $1$ on $[0,1]$ and zero elsewhere.*

**This answer is completely wrong. **

- What is the probability that $X\le\frac 14$? $\frac 14$, the integral $\int_{0}^{\frac 14} f_X (x) dx$.
- What is the probability that $Y\le\frac 14$? Well, this is the event $\{X^2 \le \frac 14\}=\{X\le\frac 12\}= \frac 12$. This is of course $\int_0^{\frac 14} f_Y(y) dy$, so clearly $f_Y$ cannot be equal to the constant $1$ on $[0,1]$!

This simple analysis can be used to derive the CDF of $Y$ and then its density, if exists, through a straightforward approach that often is all you need. The recipe is the following:
1. For a number $y$, identify the event $\{Y \le y\}$ in terms of $X$.
    - In our particular case, since $Y=X^2$, we have  $\{Y\le y\} = \{X^2 \le y\}$.
1. Manipulate the resulting event and express it in terms of $X$ so you can identify its probability through the CDF of $X$. This step involves undoing the transformation, and you need to be extra careful and attentive to details.
    - For any $y<0$ the event $\{X^2 \le y\}$ is empty, and for $y \ge 0$, we can take square roots on both sides to identify the event as $\
\hline x  & 1 & 1.5 & 3 & 4 \\
\hline\hline
p_X(x) & ? & \frac 13 & \frac{1}{12} & ? \\
\hline\hline
\end{array}$$
It is also known that  $E[X] = \frac{19}{12}$.
1. Complete the missing numbers.
1. Sketch the CDF of $X$.
1. Find the PMF for $2X+10$.
\end{prob}

\begin{prob}
Let $X$ be the RV from \ref{prob:simple_cdf}. For each of the following cases, find the PMF.
1. $Y=X^2$.
1. $Y=\min (X,3)-3$. In this case, also sketch the CDF.
\end{prob}

\begin{prob}
1. Suppose that an RV $X$ has a CDF that takes only two values. Show that $X$ there exists $c$ such that $P(X=c)=1$.
1. Suppose that an RV has a CDF that takes exactly three values. Show that there exist $a,b$ and a Bernoulli RV $Y\sim \mbox{Bern}(p)$ with $p\in (0,1)$ such that $X = a+ bY$.
\end{prob}

\begin{prob}
A CDF $F$ is said to be stochastically dominated by a CDF $G$ (equivalently, $G$ stochastically dominates $F$) if $G(x)\le F(x)$ for all $x\in \R$. We also say that the RV $Y$ stochastically dominates $X$ if $F_Y$ stochastically dominates $F_X$.
1. Show that if $X\le Y$, then $Y$ stochastically dominates $X$.
1. Find an example two RVs $X$ and $Y$ such that $Y$ stochastically dominates $X$ yet the condition in part a. fails (that is  $P(X>Y)>0$).
\end{prob}

\begin{prob}
Suppose that $X$ is a nonnegative RV with the property that for any $x>0$,  $P(X>2x)= (P(X>x))^2$. What is the distribution of $X$?
\end{prob}

\begin{prob}
I am waiting to be sentenced on a traffic violation. Researching past data, the probability of being acquitted is $20\%$ with total costs being $\$0$.  and if convicted the total costs (penalty, fees, etc.) are exponentially distributed with Expectation $\$3$
1. Write the distribution function of the total costs. Is this random variable continuous? Discrete? Neither?
1. Find the expectation of this random variable.
\end{prob}

\begin{prob}
I'm tossing a fair dice twice, independently. I win the amount of the maximal value (in USD). For example if the dice lands $2$ and $3$ (or $3$ and $2$), then  I win \$3.
1. What is the expectation and variance of my winning?
1. Assuming that one of the tosses was  $1$, what is the new expectation of my winning?
\end{prob}

\begin{prob}
The density $f_X$ of an RV $X$ is given by
$$  f_X (x) = \begin{cases} c\sin x &  0  \le x \le {\pi}\\ 0 &   \mbox{otherwise}\end{cases} $$
1. Compute $c$.
1. Compute the expectation and variance of $X$
1. Compute the expectation and variance of $\cos (X)$.
\end{prob}

\begin{prob}
Let $X\sim \mbox{Exp}(\lambda)$ for $\lambda>0$.
1. Find the density of $e^{cX}$ for $c \in \RR$.
1. Compute the variance of $e^{cX}$ for all $c$ where it is finite.
\end{prob}
\begin{prob}
Let $a,b \in [0,1]$. Show the following:
1. If $b< a^2$, then there does not exist a RV  $X$ such that $E[X]=a$ and $E[X^2]=b$.
1. If $b\ge a^2$, there exists a RV $X$  such that $E[X]=a$ and $E[X^2]=b$.
\end{prob}

\begin{prob}
Suppose that $X$ has a distribution function of the form
$$ F(x) = \begin{cases} 0  & x< 0 \\
   \frac {1}{16} & 0\le x < 1 \\
    \frac{x^2}{8} & 1 \le x < 2\\
    1 & x\ge 2\end{cases}
$$
1. Determine what type of RV $X$ is (discrete, continuous or mixed). If not continuous, find all atoms of $X$ and  calculate their probabilities.
1. Compute the expectation of $X$.
1. Find the CDF of $X^2$.
\end{prob}

\begin{prob}
Suppose that $X\sim \mbox{U}[0,1]$. Find the density of each of the following RVs:
1. $ X^2$
1. $\sqrt{X}$
1. $1/X$
1. $\cos(2X)$.
Repeat when $X\sim \mbox{Exp}(1)$.
\end{prob}

\begin{prob}
\label{prob:family}
1. A family decided to have children until they have at least one of each sex. Assume each child is equally likely to be a boy or a girl, independently of all other children. Find the probability mass function and expectation  of the number of children the family will have.
1. Repeat the first part assuming that the the probability of a baby boy is $p\in (0,1)$.
\end{prob}

\begin{prob}
\label{prob:disaster}
The probability of a disaster each day is $p$, independently of the past. Find the expected number of days until the first time we will experience two consecutive days of disasters. Generalize to $n$ consecutive days.
\end{prob}

\begin{prob}
This problem was motivated by a video I found on a YouTube channel on [Georgia Lottery](https://www.youtube.com/channel/UCf5_TXnMLpmg4nP0Sl9lRxA). A lottery ticket costs \$10. Here are the possible outcomes:
1. With probability $10^{-7}$ you win \$100,000 in cash.
1. With probability $10^{-5}$ you win \$1000 in cash.
1. With probability of $10^{-3}$ you're entered to the next drawing (identical to first). You cannot sell or transfer this right.
Let $X$ denote the expected prize value.  What is the expectation of $X$?
\end{prob}

\begin{prob}
This was motivated by a [Ted-Ed video](https://www.youtube.com/watch?v=IAiNqQi30-Y) (but it is different! we have only one sequence of tosses). Two brothers are repeatedly tossing one fair coin. Orville wins if the pattern HH appears before the pattern HT. Otherwise Wilbur wins.
1. What is the distribution of number of tosses until the game is decided?
1. What is the probability of Orville winning the game?
1. How would your answer to the second part change if the pattern HT was replaced by the pattern TH? (get ready for a surprise) [Even more surprising?](https://www.youtube.com/watch?v=Sa9jLWKrX0c)
\end{prob}

\begin{prob}
For an event $A$ write ${\bf 1}_A$ for the random variable equal to $1$ on $A$ and to $0$ on $A^c$. This random variable is known as the indicator of $A$.
1. Show that $P(A)=E [ 1_A]$.
1. Show that ${\bf 1}_{A\cap B}={\bf 1}_A {\bf 1}_B$, and that ${\bf 1}_{A^c}=1-{\bf 1}_A$.
1. By expanding $1-E [ (1-{\bf 1}_A)(1-{\bf 1}_B)(1-{\bf 1}_C)]$, recover the inclusion-exclusion formula for three sets. Explain what you're doing.
\end{prob}

\begin{prob} (Requires complex analysis) Let $X$ be $\mbox{Pois}(\lambda)$. Find the probability that $X$ is a multiple of $3$.
\end{prob}

\begin{prob}
Let $X$ be an RV with finite second moment.
1. Let $f(x) =E[ (X-x)^2]$. Show that $f$ attains a minimum at $x=E[X]$, and conclude that $E[(X-x)^2] \ge \sigma^2_X$ with equality if and only if $x= E[X]$.
1. Suppose now that in addition $X$ takes values in the interval $[a,b]$. Use the result above to show that  $\sigma^2_X \le \frac{(b-a)^2}{4}$.
\end{prob}

\begin{prob}
The probabilistic method. This is a  name for an approach using probability to solve combinatorial problems. Here's a fine example.
$12$ students and $5$ faculty are sitting at a around table. Show that not matter how they are seated, there will be $7$ adjacent seats with at least $3$ faculty members among them.

Hint. Fix any seating. Now randomly pick a seat, and let $X$ be  the (random)  number of faculty members sitting in the seven adjacent seats from the one picked going clockwise.  Compute the expectation of $X$ and show that it is larger than $2$.  Use this to show that the  probability of $\{X>3\}$ is positive. Explain why this proves the claim.
\end{prob}

\begin{prob}
At the time I wrote this problem, Mega Millions was in the news, because of a $1.6$ billion dollar jackpot. The rules of the game are the following: you pick a combination of $5$ numbers from $1$ to $75$, and an additional "mega" number between $1$ and $25$. The price of a ticket is $\$2$. Use the table on [Lotto Hub](http://www.lotteryhub.com/mega\%20millions-prizes-and-odds.php) to find what is the expected payout as a function of the jackpot, and the value of the jackpot that makes the game fair (that is: expected payout is the same as the price of ticket).
\end{prob}

\begin{prob} (the [source](https://commoninfirmities.com/2020/07/03/vaccine-probabilities/) is Prof. David Steinsaltz's blog)

[An article in the Guardian from July 2020](https://www.theguardian.com/society/2020/jul/03/im-cautiously-optimistic-imperials-robin-shattock-on-his-coronavirus-vaccine) has the following quote:
*"The success rate of vaccines at this stage of development is 10%, Shattock says, and there are already probably 10 vaccines in clinical trials, “so that means we will definitely have one."*

Below we offer two interpretations for the information given. Calculate the probability that there will be at least one successful vaccine for each of the interpretations.

1. there are exactly 10 vaccines in clinical trials and the probability of success of each one is 10%, independently of the others.
1. the number of vaccines in clinical trials is a Poisson random variable with expectation $10$, each with probability 10% of success, independently of the others.
1. Bonus. Find another acceptable interpretation and calculate the probability.
\end{prob}

\begin{prob} (Negative Binomial distribution)
Consider a sequence of independent Bernoulli trials with probability of success $p\in (0,1]$ for each. For $r\in \{1,2,\dots\}$, let $X$ denote the number of successes before the $r$-th failure.  These distributions are called negative binomial with parameters $p$ and $r$.
1. Show that the PMF of $X$ is given by
$$ p_X(k) = \begin{cases} \binom{k+r-1}{k}p^k(1-p)^{r} &  k=0,1,\dots,\\ 0 & \mbox{otherwise}\end{cases}$$
1. Let $Y\sim Geom(1-p)$. Show that  if $r=1$ then $Y-1$ and $X$ have the same distribution. Explain why.
1. Compute the expectation of $X$.
\end{prob}

\begin{prob}
Let $X\sim \mbox{Exp}(1)$ and let $p\in (0,1]$. Find a function $f$ such that $f(X)\sim \mbox{Geom}(p)$.
\end{prob}

\begin{prob}
Let $X\sim \mbox{Exp}(1)$. For any $a,b\in (0,1)$ Find two sets (unions of intervals) $I_a,I_b$ such that $P(X\in I_a) =a,~P(X\in I_b) =b$ and the events $\{X\in I_a\}$ and $\{X\in I_b\}$ are independent.
\end{prob}

\begin{prob}
Each time I hire an employee the revenue the employee will bring to my business changes by  $X\%$ each quarter, where $X$ is a random variable with expectation zero. Use an expectation argument to determine which strategy is better.
1. Hire one employee and keep for two quarters.
1. Hire a new employee each quarter.
\end{prob}

\begin{prob}
1. Show that if $X$ is an RV taking nonnegative integer values, then
$$E[X]= \sum_{n=1}^\infty P(X\ge n).$$
1. Show that if $X$ is any RV, then $E[|X|]=\int_0^\infty P(|X|>t) dt$.
1. Show that if $X$ is a nonnegative RV then
$$E[X^n]=n \int_0^\infty P(X>t)t^{n-1}dt.$$
1. Use the results of the last part to calculate $E[X^2]$ when $X\sim \mbox{Geom}(p)$ for $p\in (0,1]$ and when $X\sim \mbox{Exp}(\lambda)$. Try not to compute any  integrals, but  rather use the calculated expectation for the respective RVs.
\end{prob}

\begin{prob}
It is known that the RV $X$ has density on $[0,1]$ which is a function of the form $a+bx$.
1. It is also known that its expectation is equal to $1/2$. Find $a$ and $b$.
1. Repeat assuming now the expectation is $p$ for $p\in (0,1)$.
\end{prob}

\begin{prob}
Suppose that the reported annual salary among people seeking for unemployment benefit in some US state is an Exponential RV with expectation $\$20K$. Unemployment benefit is $80\%$ of the reported annual salary, with a cap of $\$20K$ per year. What is the expected unemployment benefit?
\end{prob}

\begin{prob}
Bus route 913 makes the 30 miles from Storrs to Hartford in a random time which is uniformly distributed between $40$ minutes and $80$ minutes. A cyclist does the same route at a time which is uniformly distributed between $55$ minutes and $65$ minutes. We assume both times are continuous RVs.
1. What is the expected travel time of the bus and of the cyclist?
1. Whose expected speed is larger?
\end{prob}

\begin{prob}
A RV $Z$ is called standard Normal (see Definition  \ref{def:normal}) if it has density
$$ f_Z(z) = \frac{1}{\sqrt{2\pi}} e^{-z^2/2}.$$
1. Compute $E[|Z|]$.
1. Compute $E[Z^2]$.
\end{prob}

{% comment %}
Mandatory TOC
{% endcomment %}
* TOC
{:toc}
