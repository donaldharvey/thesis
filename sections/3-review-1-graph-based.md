## Graph-based approaches to superpixel segmentation

These algorithms operate on pixel grid graphs as defined in definition~\ref{def:pgg} represent a pixel-based image using an undirected, weighted graph $G = (V, E)$ whose nodes have a 1--1 correspondance with all pixels and edges represent adjacency relations, where each pixel is connected to its 4 or 8 closest neighbours. Edge weights $w_{nm}$ measure the similarity between pixels. An objective function based on $G$ is typically defined and optimised by gradually adding **graph cuts** to build a segmentation.

\begin{defn}[Weighted pixel grid graphs]

A weighted pixel grid graph is a pixel grid graph $(V, E)$ and a function $w(p_1,p_2)$, where each edge $E_{p_1,p_2}$ is given a weight $w(p_1,p_2)$ based on the similarity between the connected pixels $p_1$ and $p_2$.

\end{defn}

\begin{defn}[Graph cuts and cut-sets]

A \textbf{cut} of a graph $G = (V,E)$ is a partition of the vertices $V$ into two subsets $S$ and $T$. The \textbf{cut-set} of such a cut $C = (A, B)$ is the set $\{(u,v) \in E \mid u \in A, v \in B\}$ of edges with one endpoint in $S$ and the other in $T$.

\end{defn}

### The Normalised Cuts segmentation algorithm

Normalized Cuts [@shi2000] was originally proposed for the task of classical image segmentation, and used by [@ren2003] for the first superpixel segmentation algorithm. The algorithm successively adds graph cuts, where each graph cut $C = (A,B)$ minimises the following global criterion:

\begin{equation}
NCut(A,B) := \frac{cut(A,B)}{assoc(A,V)} + \frac{cut(A,B)}{assoc(B,V)},
\end{equation}

where 

\begin{equation}
cut(A,B) := \sum_{n \in A} \sum_{m \in B} w_{nm}
\end{equation}
\begin{equation}
assoc(A,V) := \sum_{n \in A} \sum_{m \in V} w_{nm}.
\end{equation}

Minimising this objective function avoids favouring cuts in small sets of nodes by normalising the cut cost taking into account all the nodes in the graph.

It is shown that this criterion is minimized by discretising the second smallest eigenvalue for the generalised eigenvalue problem

\begin{equation}
(D - W)\vec{y} = \lambda D \vec{y}
\end{equation}

where $W(i, j) = w_ij$ and $D(i,i) = \diag(\vec{d})$ with $d_i = \sum_{j \in V} w_{ij}$ the total weight of all edges connected to node $i$.

In order to obtain superpixels, this criterion is applied recursively, using both contour and texture cues to determine weights.

Normalised cuts is computationally demanding; it has a complexity of $O(n^{3/2})$, and typical runtimes are on the order of minutes even for a single 150k pixel image. There have been attempts to speed it up, e.g. by decomposing the graph in multiple scales [@cour2005], but these still do not improve it sufficiently for it to be run in real time on typical images.

### Felzenswalb & Huttenlocher's superpixel segmentation algorithm

@felz2004 introduce another quite different graph-based approach. It could validly have instead been put into the region-based category as it grows superpixels from an initial segmentation. Starting from an initial segmentation where each pixel is its own superpixel, the algorithm processes all edges sorted by increasing weight: if an edge connects two different superpixels, these superpixels are merged if edge weight is small compared to the minimum internal difference between the superpixels, which is defined as follows:

$$
MInt(A,B) = \min \left\{Int(A) + \frac\tau{|A|}, Int(B) + \frac\tau{|B|}\right\}
$$
$$
Int(A) = \max \\ \{w_{nm} \; | \; (n,m) \in MST(A) \},
$$

where $MST(A)$ is the minimum spanning tree of $A$, a set of edges passing through all vertices that minimises the total of edge weights.
Edge weights are defined by the absolute intensity difference between pixels, i.e. $w_{ij} = |I(p_i) - I(p_j)|$, with $I(p_i)$ the intensity of pixel $p_i$.

Unlike Normalized Cuts, and distinctively for a graph-based algorithm, it runs very fast, with runtimes on the order of 0.1 seconds. Its algorithmic complexity is $O(n \log n)$. However, despite good edge adherence, it produces superpixels that are highly irregular in shape and fail to match well with visual features [@levinshtein2009]. Furthermore, it offers no way to input the target number of superpixels.


<!-- % ### The Entropy-Rate Superpixels algorithm

% Entropy-Rate Superpixels uses an objective function consisting of two components: "entropy rate" of a random walk on a graph, along with a balancing term that encourages compact and homogeneous superpixels:

% $$E(G) = H(G) + \lambda B(G)$$

% Using the notation $\mu_i = \sum_{j \in V} w(i,j) / \sum{(m,n) \in E} w(n,m)$, the entropy rate $H(G)$ is defined as

% $$
% H(G) = - \sum_{i \in V} \mu_i \sum_{j \in V} p_{i,j} \log p_{i,j}.
% $$

% The transition probabilities $p_{i,j}$ of the random walk are shown to be

% $$
% p_{i,j} = \begin{cases}
%     w(i,j) / \sum_{m \in V} w(i,m) & i \neq j, (i, j) \in E \\
%     0 & i \neq j, (i, j) \not\in E \\
%     1 - \frac1{w_i} \sum_{} & i \neq j, (i, j) \not\in E \\
% \end{cases}
% $$ -->


### Other graph-based approaches to superpixel segmentation

A couple of sentences on:

- Entropy-Rate Superpixels [@liu2011] uses an objective function consisting of two components: "entropy rate" of a random walk on a graph, along with a balancing term that encourages compact and homogeneous superpixels.
- Lattice Cuts [@moore2008]
- Pseudoboolean [@zhang2011]

