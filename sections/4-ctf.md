# The original algorithm CtF

\label{ch:ctf}

@yao2015 introduced a novel coarse-to-fine approach (henceforth referred to as CtF) that is asymptotically linear in runtime. Though it is partly inspired by SEEDS, it optimises a very different objective function that has more in common with the clustering metric of SLIC. Like SEEDS, it iteratively improves the segmentation quality via hillclimbing by exchange of boundary blocks, though iterates slightly differently over boundary blocks. Its authors claim that it beats the performance of SLIC and SEEDS both in runtime and accuracy. These claims will be analysed in chapter \ref{ch:results}. 

A significant contribution in @yao2015 is a stereo version of their algorithm which takes two images, derives depth data from their difference, and uses this to build a superpixrl segmentation algorithm that takes the depths of objects into account. This is beyond the scope of this report, and we focus only on their monocular algorithm in this chapter.

## Summary of CtF

\begin{figure}[h]
\includegraphics[width=\textwidth]{bears.png}
\caption{Coarse-to-fine updates start at the coarse level (level 4 on the left) and proceed iteratively to levels 3, 2, 1 and 0, increasingly improving boundary adherence at each level.}
\end{figure}

CtF utilises an energy function with three terms (\ref{ctf:energy}), one for shape regularity, boundary length and reconstruction error. The latter two are optional and can be given different weights to allow the user to prioritise different properties. The exact terms are selected for their ease of computation after an incremental segmentation update (\ref{ctf:inc-energy}). 

The algorithm starts with a grid of superpixels based on the target input, and creates a grid of blocks by dividing each superpixel into quarters (section \ref{ctf:init}). The parameters (primarily mean colours and centroids) used by the energy function to compute the energy are stored for this initial segmentation (definition \ref{def:ctf:blocks}). Then, a priority queue of boundary blocks is initialised, with blocks being added row-by-row. For each boundary block in the queue, it is first checked that it is possible for the block to be relabeled (i.e., moved to a different superpixel) whilst preserving local connectivity, as well as satisfying an optional minimum size constraint (section \ref{ctf:queue}). If there is no violation, a relabelling of the block to the label of each member of its 4-neighbourhood is attempted. For each potential move, the energy delta that would result from the move is computed (section \ref{ctf:relabel}). The best potential move is then made, provided it decreases the overall energy. If a move is made, the neighbours of this block are, if they are now boundary blocks, pushed to the end of the queue. This process continues until the queue is empty (or a maximum number of 400k iterations is reached). Then, a new level starts: the blocks are split into quarters and the process runs again (section \ref{sec:ctf:splitting}). This continues each block contains exactly one pixel.

## Initialisation of block grids and superpixel structure

\label{ctf:init}

CtF has a slightly unusual approach to grid creation in practice, creating a grid that is uniform except at the edges. The grid is initialised using grid squares have length $L = \floor{\sqrt{n/k}}$, for a target number of superpixels $k$ and number of pixels $n$. If this grid does not exactly fit into the pixel grid, then the edges are cut off, creating rectangular superpixels at the bottom and right of the image.

Blocks are then initialised by dividing each superpixel further, at least into quarters, or more if the maximum block side length would be exceeded (by default 16 pixels). 
We denote the block grid at a given level $l$ by $\mathcal{B}_l$, a grid with the block at index $(i,j)$ being $B_{ij}$. The first level $l$ is determined by the maximum side length $m$ of rectangles in the initial block grid:

$$
l = \ceil{\log_2{m}}.
$$

\begin{defn}[Summed quantities]
\label{def:sums}
We write the sum of colours in a region $R$ as $\Sum(R) = \displaystyle \sum_{p \in R} I(p)$ and the sum of squared colours as $\Sum2(R) = \displaystyle \sum_{p \in R} (I(p))^2$. We similary denote the sum of position vectors $\displaystyle \PosSum(R) = \sum_{p \in R} p$ and position vectors with squared coordinates $\displaystyle \PosSum2(R) = \sum_{p \in R} p^2$. 
\end{defn}

\begin{defn}
\label{def:ctf:blocks}

Each block $B \in \mathcal{B}_l$ contains the following data:

\begin{itemize}
\item $\mathrm{ULC}(B)$: the pixel-grid coordinates of the upper-left corner (ULC) of the block
\item $(w(B), h(B))$: the width and height of the block in pixels
\item $s(B)$: the superpixel to which all the block's pixels belong
\item $\mathrm{Sums}(B)$: a list of precomputed sums of colours and positions: $( \Sum(B), \Sum2(B), \PosSum(B), \PosSum2(B) )$
\end{itemize}
\end{defn}

\begin{defn}
\label{def:sp-structure}
The superpixel structure of a segmentation $S$ stores, for each individual superpixel $S_i$:
\begin{itemize}
\item $B(S_i)$, a set of blocks of pixels that it contains 
\item $|S_i|$, the area of the superpixel
\item $L(S_i)$, the boundary length of the superpixel, measuring the perimeter of the union of blocks that comprise it
\item $\mathrm{Sums}(S_i)$, the summed quantities in Definition~\ref{def:sums} for the superpixel
\end{itemize}
\end{defn}

The purpose of storing the sums, boundary lengths and areas of blocks and superpixels is efficient computation of energy deltas for potential moves; see Lemma \ref{lem:energy-delta}.

## Energy as a reconstruction error with regularisation constraints

\begin{defn}
\label{def:ctf-energy-col}
The colour energy $E_\mcol(S_i)$ of a superpixel $S_i$ is the sum of squared colour deviations from the mean of each superpixel, which is exactly the reconstruction error defined in Defintion~\ref{def:re}. As there, we use $\mcol(S_i)$ to denote the mean colour of superpixel $S_i$. Then 

$$ E_\mcol(S_i) = \sum_{p \in S_i} (I(p) - \mcol(S_i))^2. $$
\end{defn}

\begin{defn}
\label{def:ctf-energy-reg}
The regularisation energy $E_\mathrm{reg}(S_i)$ of a superpixel $S_i$ is the sum of squared distances from the centroid,

$$ E_\mathrm{reg}(S_i) = \sum_{p \in S_i} \norm{p - \mu(S_i)}^2. $$ 

This encourages uniform, localised superpixels.
\end{defn}

\begin{defn}
\label{def:ctf-energy-bound}
The boundary energy $E_\mathrm{b}(S_i)$ of a superpixel $S_i$ simply measures its boundary length, i.e.

$$ E_\mathrm{b}(S_i) = L(S_i). $$

Along with \ref{def:ctf-energy-reg}, this encourages compact superpixels.
\end{defn}

\begin{defn}
\label{def:ctf-energy}
The energy function optimised by CtF is the sum of the above three energies, where the latter two weighted by parameters $\lambda_\mathrm{reg}$ $\lambda_\mathrm{b}$:
$$
E(S) = \sum_{S_i \in S} \left( E_\mcol(S_i) + \lambda_\mathrm{reg} E_\mathrm{reg}(S_i) + \lambda_\mathrm{b} E_\mathrm{b}(S_i) \right)
% E(S) = \underbrace{
%     \addstackgap[4pt]{
%         $\displaystyle \sum_p E_{\rm col}(s(p))$
%     }
% }_{\text{\small reconstruction error}}
% \; + \; 
% \overbrace{
%     \addstackgap[4pt]{
%         $\displaystyle \lambda_{\rm reg} \sum_p E_{\rm reg}(s(p))$
%     }
% }^\text{\small regularisation term} 
% \; + \;
% \underbrace{
%     \addstackgap[4pt]{
%         $\displaystyle \lambda_{\rm b} \sum_p \sum_{q \in \mathcal{N}_8} E_{\rm b}(s(p), s(q))$
%     }
% }_\text{\small boundary length term}
$$
\end{defn}

## Queue of boundary blocks and local connectivity constraint

\label{ctf:queue}

\begin{defn}
A block $B$ is called a \textbf{boundary block} if for some $A \in \mathcal{N}_4(B)$, $s(A) \neq s(B)$.
\end{defn}

\begin{defn}
A \textbf{queue} is a list of items where for iteration, elements are taken (\textit{popped}) from the front of the queue, and for adding new elements, appended (\textit(pushed)) to the back of the queue.
\end{defn}

All initial boundary blocks are put into a queue row-by-row, and any new boundary blocks will added to the end of this queue.

Each step in the iteration process for a given level pops a boundary block $B$ from the queue. Before determining potential moves for the block, two constraints are checked. Firstly, it is ensured that \todo{define me}relabelling the block does not result in $s(B) - B$ becoming disconnected. Moves of such a block are called {\em forbidden} in \cite[section~3]{yao2015}. However, the global connectivity of $S-B$ is slow to check. Hence, in practice, the actual connectivity should be {\em local} as clarified below.

\begin{defn}
\label{def:connectivity}
A removal of a boundary block $B$ from a superpixel $s(B)$ respects the {\em local connectivity} of $s(B)$ if the 8-neighborhood of $B$ within $s(B) - B$ is connected. 
\end{defn}

The 3 pictures in \ref{fig:connectivity} exemplify some (but not all) forbidden moves. We justify in Lemma \ref{lem:connectivity} why the local connectivity can be checked in a constant time.

## Incremental energy improvement via hillclimbing

\label{ctf:relabel}

If the move is permitted by connectivity constraints, it is also checked against a minimum size constraint: a move is not allowed if it causes a superpixel to become less than a quarter of its initial size. If this constraint is also satisfied, then a list of potential relabels is created:

$$\textrm{relabels}(B) = \{ s(A) \mid A \in \mathcal{N}_4(B); s(A) \neq s(A))\}$$

We then compute the energy delta $\Delta E = E(T) - E(S)$, for each relabelling in $\textrm{relabels}(B)$ and its corresponding resulting segmentation $T$.
The relabel with the best corresponding energy delta is selected, and performed, as long as it is negative.
After $B$ has been relabelled, only its 4 neigboring blocks can change their boundary status. Any new boundary blocks are added to the end of the priority queue.

## Level transitions

\label{sec:ctf:splitting}

When the queue of boundary blocks is empty, provided there remain blocks containing multiple pixels, a transition to the next level occurs where a new block grid $\mathcal{B}_{l-1}$ is created, and each block from the previous grid is split. Splitting a block subdivides each side into 2 almost equal parts, whose lengths differ by at most 1 pixel. 
1-pixel sides are not subdivided, so 1-pixel wide blocks are subdivided into 2 blocks.

The sums in Definition \ref{def:sums} are then recomputed for the new block grid $\mathcal{B}_{l-1}$

It is this splitting that allows CtF to converge to low energies rapidly.

## Example outputs

- k = 100, all terms default
- k = 400, all terms default
- k = 1000, all terms default
- k = 500, colour only
- k = 500, colour and reg only
- k = 500, colour main, reg and boundary small

## Complexity analysis

\begin{lem}
\label{lem:grid-setup}
Setting up the block grid structure takes at most linear time $O(n)$ at the beginning of each level.
\end{lem}
\begin{proof}
The grid of blocks is initialized in constant time. The complexity of adding the data in Definition~\ref{def:ctf:blocks} is added in $O(n)$, since in order to compute the sums a lookup is required for each pixel. 

\begin{lem}
\label{lem:bblock-setup}
Finding the set of boundary blocks takes time $O(b)$ at the beginning of each level, where $b$ is the number of blocks in the grid $\mathcal{B}_l$ for level $l$.
\end{lem}
\begin{proof}
The set of boundary blocks is computed by iterating over each block $B \in \mathcal{B}_l$ and adding it if it is not already in the set and it has a different superpixel to at least one member $A \in \mathcal{N}_4(B)$. This requires $O(b)$ lookups.

\begin{lem}
\label{lem:connectivity}
For any boundary block $B$ moving from a superpixel $S_i$ to another superpixel $S_j$, 
the {\em local connectivity} of $S_i-B$ can be checked in a constant time.
\end{lem}
\begin{proof}
We go around the circular 8-neighbourhood $\mathcal{N}_8(B)$, consider all blocks of $S-B$ as isolated vertices, add an edge between vertices $u,v$ if the corresponding blocks in $\mathcal{N}_8(B)$ share a common side.
Then $S-B$ is locally connected around $B$ if and only if the resulting graph on at most 9 vertices is connected. We can compute this very efficiently by precomputing the connectivity of all $2^9 = 512$ combinations of graphs, which can be done in constant time.
\end{proof} 

\begin{lem}
\label{lem:update}
The potential energy delta from moving any block $B_{ij}$ from a superpixel $S_a$ to an adjacent superpixel $S_b$ can be computed in a constant time. Furthermore, on completing this move, the superpixel structure can also be updated in constant time. 
\end{lem}
\begin{proof}
FIXME
All sums of colors over the block $B$ are subtracted from the corresponding sums of $S_i$ and are added to the sums of $S_j$.
We change the superpixel index of $B$ from $i$ to $j$.

So all steps performed on a single queued boundary block can be performed in constant time.


\begin{thm}
\label{thm:iCtF-time}
The CtF algorithm segmenting an image of $n$ pixels into a target of $k$ superpixels has the asymptotic complexity $O(n+q)$.
\end{thm}
\begin{proof}
By Lemma~\ref{lem:grid-setup}, setting up the block grid takes time $O(n)$ for each level. By Lemma~\ref{lem:bblock-setup}, filling the queue of initial boundary blocks takes time $O(b)$ for each level. $b \leq n$ for all levels, so this also takes a maximum amount of time $O(n)$. 

Since blocks have a maximum initial size, the number of levels $\ceil{\log_2{m}}$ is constant, so the total time taken setting up the block grid and boundary block queue for the entire algorithm is $O(n)$.

By Lemmas~\ref{lem:connectivity}, \ref{lem:update} the time for Stage~4 is proportional to the number $q$ of boundary blocks processed in the priority queue, because each boundary block is adjacent to at most 3 other superpixels.
\end{proof}
