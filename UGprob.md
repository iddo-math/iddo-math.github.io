---
layout: default
title: LaTeX-like Theorems & Figures (Section-based)
---

## Right Triangles

\begin{theorem}[Pythagoras]\label{thm:pyth}
For a right triangle with legs $a,b$ and hypotenuse $c$,
\begin{equation}\label{eq:py}
a^2 + b^2 = c^2.
\end{equation}
\end{theorem}

As shown in Theorem~\ref{thm:pyth}, equation $\eqref{eq:py}$ holds.

\begin{figure}\label{fig:triangle}
\includegraphics[width=0.6\textwidth]{/assets/img/triangle.png}
\caption{A right triangle.}
\end{figure}

See Figure~\ref{fig:triangle}.

\begin{lemma}\label{lem:leg}
If $a=3$ and $b=4$, then $c=5$.
\end{lemma}

Theorem/Lemma share numbering: compare Theorem~\ref{thm:pyth} and Lemma~\ref{lem:leg}.

## Another Section

\begin{proposition}\label{prop:next}
This starts a new section; shared theorem counter resets, so this is Proposition 2.1.
\end{proposition}

Equation numbering also resets: $\begin{equation}\label{eq:next} x^2 - 1 = (x-1)(x+1) \end{equation}$
