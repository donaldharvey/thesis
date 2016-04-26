# Our improved algorithm iCtF
\label{ch:ictf}

In looking for a place to contribute to the state-of-the-art in superpixel segmentation, we felt that CtF represented a novel and interesting approach that has great potential for improvement whilst already performing as well or better than other established, linear state-of-the-art argorithms (SLIC and SEEDS). We noted that in general, gradient descent and hillclimbing optimization methods find a better minimum if a starting point is chosen close enough to a global minimum [@blum2003]. Therefore, in @us we developed a novel initialisation method, that quickly creates an initial mesh of rectilinear polygons. This mesh is based on detecting strong vertical and horizontal edges in the input image, and gives rise to a better reconstruction error minimum in a course-to-fine optimization at low cost to runtime, memory and complexity. In particular, our approach focuses on providing more densely-packed superpixels in perceptually dense, complex regions, and less dense superpixels in uniform regions such as areas of sky.

## Phase 1: Adaptive initialisation

In summary, our approach finds strong edges in a given image, and uses these to generate a non-uniform mesh of rectangular blocks. These blocks are iteratively merged to create a mesh of rectilinear polygons in such a way that the energy function remains as small as possible, up to a maximum total increase or until a minimum number of superpixels is reached. The output mesh is then used as an input to a slightly modified version of the CtF algorithm of @yao2015 described in chapter 3, instead of the initial grid described in \ref{sec:ctf:grid}.

### Fast detection of strong horizontal and vertical edges

Along with the input image, the initialisation process takes as its only required input the target maximum number of superpixels $k$.

We define the parameter $l := \ceil{n/k}$ as the expected length of a uniform square superpixel.
We consider all horizontal edges $[j,j + l] \times i$ and vertical edges $j \times [i,i+l]$ along pixel boundaries, where $i,j \geq 1$, $i + l \leq w$ and $j + l \geq h$.

\begin{defn}
The \textbf{contrast} of an edge $E$ with length $l$ is the sum of colours in the two rectangles $l \times t$ on both sides of $E$, i.e.

$$\mathrm{contrast}(E) = \abs{\sum_{p \, \in R_1} I(p) - \sum_{p \, \in R_2} I(p)}$$

where $R_1 = [0, l] \times [0,t]$ and $R_2 = [0, l] \times [0, -t]$ (with the obvious analogue in the vertical case)
\end{defn}

\begin{defn}
\label{def:strong-edges}
An edge $E$ is called \textbf{$\bm{k}$-th strong} if $\mathrm{contrast}(E)$ is a global maximum amongst all edges parallel to $E$ after removing all previous $k-1$ strong edges with their small neighborhoods of a given size (3 pixels by default). 
\end{defn}

The algorithm selects the first $2k$ horizontal and $2k$ vertical edges according to this definition. The factor 2 comes from the fact that each resulting superpixel possessing a bounding box with 2 horizontal and 2 vertical edges.

### Rectilinear grid creation and structure initialisation

Strong edges from Definition~\ref{def:strong-edges} generate a rectilinear grid as follows.

\begin{defn}
\label{def:edge-grid}
For any horizontal and vertical strong edges in an image $I$, the \textbf{edge grid} is obtained by extending each strong edge in both directions to the boundary of $I$.
\end{defn}

\missingfigure{Show strong edges and resulting grid}

The grid generated from strong edges gives rise to a better-adapted initial segmentation than the regular grid used by most algorithms. However, large regions of almost constant colors such as sky can be divided by extended edges into unnecessarily small blocks. In order to remedy this issue, we attempt to merge such blocks in the following stage, in such a way that minimises the addition to the reconstruction error.

Before the merging process begins, we must set up the superpixel structure from which energies can be efficiently calculated. This means computing sums of colours, and optionally positions, over the block grid. Since this is a subset of the data we need in CtF (see Definition~\ref{def:ctf:blocks}), we initialise that data now. We use a tree-like structure where each block stores pointers to the blocks into which it will eventually be split.

\begin{defn}[Block tree]

The \textbf{block tree} is a tree-like structure containing blocks of pixels at multiple levels. Blocks are stored in a sequence of grids $\mathcal{B} = \{\mathcal{B}_l, ..., \mathcal{B}_0\}$ where $l$ is the initial level. Each block $B$ stores the same data as in Definition~\ref{def:ctf:blocks}, with the addition of an extra field $\mathrm{children}(B)$ storing references to the subblocks of $B$ - that is, each block $\{B_1, B_2, ...\}$ in the following level's grid whose union is equal to $B$.

\end{defn}

The purpose of the set $\mathrm{children}(B)$ of references to the child blocks is to allow the block splitting process of CtF (\ref{ctf:splitting}) to proceed more efficiently. When setting up the blocks for the top level $l$, rather than computing the sums for that level directly, we instead compute the sums based on those of the previous level, hence avoiding the need to recompute the sums after each level iteration as in subsection \ref{ctf:splitting}.

### Computing energy and merging adjacent superpixels with minimum energy

For each superpixel in the initial grid $S_i \in S = \mathcal{B}_l$ (since in the initial grid each block is a superpixel), we compute the reconstruction error $E(S_i) = \sum_{p \in S_i} (I(p) - \mathrm{col}(S_i))^2$.

\begin{lem} \label{lem:merge-cost}
The cost of merging two superpixels $S_i, S_j$ is given by 

$$
E(S_i, S_j) = E(S_i \cup S_j) - E(S_i) - E(S_j)
$$

We can directly compute $E(S_i \cup S_j)$ using the stored sums for $S_i$ and $S_j$.

\end{lem}

\begin{proof}
The energy $E(S_i)$ can be written

\begin{equation}
\begin{split}
    E(S_i) 
        & = \sum_{p \in S_i} ( I(p) - \mathrm{col}(S_i) )^2 \\
        & = \sum_{p \in S_i} (I(p)^2 - 2 \, \mathrm{col}(S_i) \, I(p) + \mathrm{col}(S_i)^2) \\
        & = \sum_{p \in S_i} {I(p)^2} - 2\, \mathrm{col}(S_i) \, \left( \sum_{p \in S_i} I(p) \right) + |S_i| \left( \mathrm{col}(S_i) \right)^2 \\
        & = \mathrm{sum2}(S_i) - 2 \frac{(\mathrm{sum}(S_i))^2}{\abs{S_i}} + \frac{(\mathrm{sum}(S_i))^2}{\abs{S_i}} \\
        & = \mathrm{sum2}(S_i) - \frac{(\mathrm{sum}(S_i))^2}{\abs{S_i}}
\end{split}
\end{equation}

Thus, $$E(S_i \cup S_j) = \mathrm{sum2}(S_i) + \mathrm{sum2}(S_j) - \frac{(\mathrm{sum}(S_i))^2 + (\mathrm{sum}(S_j))^2}{\abs{S_i} + \abs{S_j}}$$

\end{proof} 

We proceed by computing the cost $E(S_i,S_j)$ of merging for each adjacent pair $S_i$, $S_j$. This cost can be 0 only if $S_i,S_j$ have $\mathrm{col}(S_i) = \mathrm{col}(S_j)$. Additionally, two superpixels $S_i,S_j$ may share more than one edge, e.g. a connected chain of edges.
If the intersection $S_i\cap S_j$ is disconnected, e.g. one edge $e$ and a vertex $v\not\in e$, we set $E(S_i,S_j)=+\infty$, so the superpixels $S_i,S_j$ will not merge to avoid harder cases when a superpixel may touch itself. 

All the possible mergers are ordered by cost. We then take the top merger and perform it, updating the list with the costs of the superpixels affected by the merger. We repeat these steps until a total cost increase is reached, or a minimum target number of superpixels is reached. The default values for these parameters are, respectively, 3\% of the original total reconstruction error, and half of the superpixels produced in the initial edge grid. 

### Example initialisations

\missingfigure[figheight=6cm]{Images for k=100}
\missingfigure[figheight=6cm]{Images for k=400}
\missingfigure[figheight=6cm]{Images for k=1000}

\newpage

## Adaptive initialisation has asymptotic complexity that is linear in $n$ 

\begin{lem}
\label{lem:strong-edge}
In an image of $n$ pixels, $k$ strong edges are detected in time $O(kn)$.
\end{lem}
\begin{proof}
Computing the contrasts of all edges is equivalent to convolving the image $I$ with the mask having $+1$ in the pixels of $[0,l]\times[0,t]$ and $-1$ in the pixels of $[0,l]\times[-t,0]$, see Fig.~\ref{fig:sums-colors}.
Let $c(i,j) = I((i,j))$ be the colour of a pixel $(i, j)$. All sums $s(i,j)=\sum\limits_{q=i}^{i+t-1} c(q,j)$ in the vertical columns of the size $t$ can be found in time $O(n)$:
First we find the initial sum $b(i,0)$ by the brute-force additions for each $i=1,\dots,w$.
Then the sum $s(i+1,j)=s(i,j)+c(i+t,j)-c(i,j)$ in every lower column is obtained by adding a new color at the bottom pixel $(i+t,j)$ and subtracting the color at the top pixel $(i,j)$.
The sum $r(i,j)=\sum\limits_{q=j}^{j+t-1} s(i,q)$ over the rectangle with the top left corner $(i,j)$ is computed using the initial values $r(0,j)$ and recurrence relation $r(i,j+1)=r(i,j)+s(i,j+t)-s(i,j)$.
\end{proof}

\medskip

\begin{lem}
\label{lem:block-sums}
Let $S$ be a superpixel segmentation with segments $\{S_1, \dots, \dots, S_k \}$. All the values $|S_i|,\csum(S_i),\csum2(S_i)$ $\forall i$ can be found in time $O(n)$ independent of $k$.
\end{lem}
\begin{proof}
We recursively compute all sums for each block $B$ by adding the corresponding sums from each of $\mathrm{children}(B)$.
Since, for each single-pixel block $B=\{p\}$, we have $|B|=1$, $\csum(B)=I(p)$, $\csum2(B)=\Big(I(p)\Big)^2$, we need only $O(n)+O(n/4)+O(n/16)+\cdots=O(n)$ additions to compute the sums for all blocks.
For each superpixel $S_i$, we find $|S_i|,\csum(S_i),\csum2(S_i)$ by adding the sums from all blocks in $S_i$ in time $O(|S_i|)$, so the total time is $O(n)$.
\end{proof}

\medskip

\begin{lem}
\label{lem:energy-merge}
The cost of merging $E(S_i,S_j)$ in (\ref{lem:merge-cost}) is found in a constant time.
\end{lem}
\begin{proof}
By Lemma~\ref{lem:merge-cost}, the only data that is needed to compute $E(S_i, S_j)$ are the sums and areas of $S_i$ and $S_j$, which can be looked up in the superpixel structure in \ref{def:sp-structure} in constant time.
\end{proof}

\medskip

\begin{lem}
\label{lem:merge-time}
A superpixel segmentation of $k$ rectangular superpixels has at most $O(k)$ pairs $(S_i,S_j)$ of adjacent superpixels.
In time $O(k\log k)$ one can find and merge $(S_i,S_j)$ with a minimal cost $E(S_i,S_j)$ 
updating the costs of all pairs.
\end{lem}
\begin{proof}
Since the common boundary of $S_i,S_j$ grows over time, we store the list of all common edges in the binary {\em edge tree} indexed by $\key(S_i,S_j)$, which allows a fast insertion and deletion of new pairs of adjacent supeprixels.
To quickly find $\key(S_i,S_j)$ and the corresponding pair of adjacent superpixels with a minimum cost $E(S_i,S_j)$, we put all keys into the binary {\em cost tree} indexed by $E(S_i,S_j)$.
\smallskip

All $k$ superpixels form a planar network with $f$ bounded faces, $g$ edges, where each pair of adjacent supeprixels is represented by one edge.
Since each face $f$ has at least $3f$ edges, the doubled number of edges $2g$ is at least $3f$, so $f\leq\dfrac{2}{3}g$.
The Euler formula $k-g+f=1$ gives $1\leq k-g+\dfrac{2}{3}g$, hence $g\leq  3(k-1)$. 
\smallskip

Then both binary trees above have the size $O(k)$.
The first element in the cost tree has the minimum cost $E(S_i,S_j)$ and can be found and removed in a constant time.
The search for the corresponding $\key(S_i,S_j)$ in the edge tree in time $O(\log k)$ leads to the list of common edges of the superpixels $S_i,S_j$.
\smallskip

The edge grid from Definition~\ref{def:edge-grid} is converted into a mesh using the OpenMesh library \cite{OpenMesh}.
Then each common edge is removed by the $\mathrm{collapse}$ and $\mathrm{remove\_edge}$ operations from OpenMesh taking a constant time.
For each of remaining $O(k)$ edges of $S_i\cup S_j$ on the boundary of another superpixel $S$, the cost $E(S,S_i\cup S_j)$ is computed by Lemma~\ref{lem:merge-cost} and is added to the cost tree in time $O(\log k)$.
\end{proof}

\begin{thm}
\label{thm:iCtF-time}
The adaptive initialisation phase creating an initial segmentation of at most $k$ superpixels has the asymptotic complexity $O(nk+k^2\log k)$.
\end{thm}
\begin{proof}
By Lemma~\ref{lem:strong-edge}, detecting strong edges has the complexity $O(kn)$.
All superpixels are subdivided in time $O(n)$ by Lemma~\ref{lem:block-sums}.
Merging takes place for at most $O(k)$ pairs of superpixels, each pair in time $O(k\log k)$ by Lemma~\ref{lem:merge-time}.
\end{proof}

## Phase 2: Coarse-to-fine optimisation

Our adaptive initialisation phase produces a set of $k$ initial rectilinear superpixels. Coarse-to-fine optimisation then resumes, starting from creating a FIFO queue of boundary blocks. Our implementation of CtF differs slightly from that of @yao2015 in a number of ways. Firstly, we have already computed the required sums for the initial set of blocks. Our tree-like block structure along with the series of block grids for each level allows us to avoid recomputing sums.

\toadd{Choice of CtF parameters}

\toadd{FINISH THIS SECTION!}

## Example outputs

Fig. \ref{fig:ictf-l-by-l} on the following page shows example outputs for three different BSDS500 images. Appendix \ref{app:examples} contains further examples, including some larger non-BSDS images. 

\begin{figure}[H]

\centering
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-1/out-init.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-1/out-init-mean.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-2/out-init.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-2/out-init-mean.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-3/out-init.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-3/out-init-mean.png}
    \end{subfigure}\,
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-1/out-4.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-1/out-4-mean.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-2/out-4.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-2/out-4-mean.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-3/out-4.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-3/out-4-mean.png}
    \end{subfigure}\,
    \begin{subfigure}[b]{0.32\textwidth}
        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-1/out-0.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-1/out-0-mean.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-2/out-0.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-2/out-0-mean.png}

        \vspace{1.1mm}
        
        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-3/out-0.png}

        \vspace{1.1mm}

        \includegraphics[width=\textwidth]{iCtF-l-by-l-example-3/out-0-mean.png}
    \end{subfigure}
    \caption{iCtF segmentations for a few BSDS500 images level-by-level, with superpixel boundaries in upper rows and reconstructed images with mean colours in lower rows. The left-most images are the initial segmentations; the middle after three splittings of the blocks; the right-most at the end of the segmentation process. }\label{fig:ictf-l-by-l}

\end{figure} 

