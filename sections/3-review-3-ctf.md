## Approaches to superpixel segmentation using coarse-to-fine optimisation

Algorithms in this family use some initial segmentation (often just a regular grid) and operate on blocks of pixels rather than individual pixels. As the algorithm progresses, the size of these blocks decreases. The motivation for this is that moving large blocks of pixels at once can allow the algorithm to converge quickly in its initial stages and then refine its quality in the latter stages.

### SEEDS: Superpixels Extracted via Energy-Driven Sampling

Superpixels Extracted via Energy-Driven Sampling (SEEDS) [@vandenbergh2012] was the first approach to use this coarse-to-fine methodology. It starts from an initial regular grid of superpixels and using initially large blocks, exchanges blocks between the neighbouring superpixels. SEEDS uses an objective function that is carefully chosen to be easily re-evaluated for a proposed block move, and operates via hill-climbing, i.e. proposed moves are accepted only if the objective function increases. As the algorithm progresses, the block size decreases down to pixel level.

The energy function that is optimised by SEEDS has the form

$$
E(S) = H(S) + \gamma G(S)
$$
where $H(S)$ evaluates the colour distribution of the superpixels in $S$ and $G(S)$ is an optional smoothing term, with $\gamma$ its weight. Several choices are considered for $H(S)$, with the authors ultimately selecting the following:

$$
H(S) = \sum_{s \in S} \sum_{q=1}^{Q} h_s(q)^2
$$

where $h_s$ represents the colour histogram of superpixel $s$, such that $h_s(q)$ is the fraction of pixels in bin $q$, with $Q$ the total number of bins.

The smoothing term $G(S)$ is based on histograms of superpixel labels: let $g_R$ represent the label histogram of an area of pixels $R$, one superpixel per bin, with $g_R(k)$ being the fraction of pixels with label $k$. Then

$$
G(S) = \sum_{i}^n \sum_k (g_{R_i}(k))^2
$$

where $R_i$ is the 3x3 neighbourhood around pixel $i$.

It is shown by @vandenbergh2012 that this choice of histogram-based energy function can be rapidly evaluated by computing intersections of histograms. 

\toadd{finish, justify $O(N)$ and evaluate}
\vspace{8cm}


### Coarse-to-fine Topologically Preserving Segmentation

The algorithm introduced by @yao2015 is a central focus of this paper and will be examined in detail in the following chapter.

