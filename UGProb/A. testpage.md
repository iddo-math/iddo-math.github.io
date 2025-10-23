---
layout: latex
title: LaTeX-like Theorems & Figures (Section-based)
---
Let's look at what we created.
\section*{The fundamentals!}
\begin{lem}[Nice and sweet!]\tlabel{good_one}
\end{lem}
\begin{prop}[Pythagoras]\tlabel{pyth}
Consider a right triangle with sides $a,b$ and hypothenuse \(c\). Then 
\begin{align}
\label{eq:pyth}
{\mathcal A}
\end{align}
\end{prop}
\section*{Generalization}\tlabel{blah}
\begin{thm}[Law of \(\cos\)ines]\tlabel{good_one}
Consider any triangle with sides \(a,b,c\) and angle \(\theta\) between the first two sides. Then 
\begin{empheq}\label{eq:cosines}
c^2 = a^2+ b^2 -2ab \cos\theta
\end{empheq}
\end{thm}
This is Theorem \ref{good_one}

Can you see why \eqref{eq:pyth} is a special case of \eqref{eq:cosines}?

I'll have my notes here!

This is so awesome!

# New section 
Right? 
## Another New Section? 
### Great subsubsection
#### Great subsubsubsub? 

# Next voila!

<!-- Must be included --> 
* Table of Contents
{:toc}



