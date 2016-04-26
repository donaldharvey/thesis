## Region-based approaches to supepixel segmentation

Algorithms in this family typically start from an initial set of centres from which superpixels are incrementally grown by adding pixels.

### The Simple Linear Iterative Clustering algorithm

Simple Linear Iterative Clustering (SLIC) [@achanta2012] is unique in its combination of simplicity, accuracy and speed, and rightly has received broad attention and application. It utilises a slightly modified form of $k$-means clustering, operating in 5-dimensional $[labxy]$ space, where $[lab]$ is the pixel's colour vector in CIELAB colour space (where colour distances correspond well to human-perceived colour differences; see \ref{cielab} for an in-depth definition), and $[xy]$ is the pixel's location in the image. It begins by dividing the image into a regular grid based on the target number of superpixels, and for each grid element selects a centre for that superpixel. The centre with the lowest gradient position in a 3x3 neighbourhood is chosen, to reduce the chances of being placed at an edge or a noisy pixel.

\begin{defn}[k-means clustering]
Given a set of data points $\{x_1, ..., x_N\}$, with $x_i \in \R^n$  $\forall i$, $k$-means clustering aims to partition the points into $k$ clusters, sets $X = \{X_1, X_2, ..., X_k \}$ in such a way that minimises the sum

$$\sum_{i=1}^k \sum_{x \in X_i} D(x, \mu(X_i))$$

where $D: \R^n \times \R^n \to [0, \infty)$ is some distance metric between points (often just the Euclidean norm) and $\mu(X_i)$ is the centroid of points in $X_i$.
\end{defn}

For each centre, $k$-means clustering is then performed, using a search window twice the size of the grid interval. The distance metric used is not the standard Euclidean metric, but the following:

$$
D(a, b) = d_{lab}(a, b) + \frac{m}{S} d_{xy}(a, b)
$$

where $d_{lab}$ and $d_{xy}$ are the standard Euclidean metrics in $\R^3$ and $\R^2$ respectively; \label{sec:rev:slic:compactness}$m$ is a compactness parameter determining the extent to which spacial proximity is emphasised and $S$ the grid interval, which is determined by the size of the image and the target number of superpixels.

After this clustering, which associates every pixel in the image with a centre, the centres are then updated using the mean $labxy$ vector of all the pixels in the cluster. The process of associating pixels with the nearest cluster centres and recomputing the centres is iteratively repeated until convergence, which in almost all cases happens within 10 iterations.  
Finally, a connectivity-enforcement step occurs, where disjoint segments are relabelled with the labels of the largest neighbouring cluster.

The time-complexity of any k-means clustering is $O(kni)$, where $n$ is the number of points, $k$ the number of cluster centres and $i$ the number of iterations. SLIC achieves $O(n)$ complexity, since $i$ is constant and in each iteration each point is compared to no more than 8 cluster centres; furthermore, the connectivity-enforcement step is $O(n)$ complex and takes no more than 10% of SLIC's total runtime. This linear complexity means that it beats the performance of @felz2004 on large images, and has comparable performance at $n = 150{\rm K}$ pixels.

SLIC also produces visually appealing superpixels that are uniform in size and compact. Its accuracy is not the best in class due to its locality, but it is nonetheless strong and has proved good enough for many applications to higher-level problems.

### The Linear Spectral Clustering algorithm

Linear Spectral Clustering (LSC) [@li2015] draws heavily from SLIC, attempting to improve its boundary adherence and its ability to capture global image properties. Its proposal drew from a proof [@dhillon2007] that K-way normalized cuts in the original pixel space is identical to weighted K-means clustering in a high dimensional
feature space. Investigating this link, the authors developed an algorithm which approximates normalized cuts by performing weighted K-means clustering in 10-dimensional feature space.

The algorithm begins by mapping the $labxy$ vector of each pixel to a weighted point in the 10-dimensional feature space. The choice of initial centres is the same as for SLIC, with their corresponding feature vectorsused as initial weighted means of the corresponding clusters. The algorithm then proceeds as for SLIC until the clusters converge.

The final connectivity-enforcement step is slightly different: isolated superpixels less than a quarter of the expected
superpixel size are merged with the best neighboring superpixel. (When there are multiple neighbouring superpixels, the closest one in the feature
space is chosen.)

Similarly to SLIC, LSC is also of linear complexity $O(n)$.

\toadd{add more on LSC}

<!-- ### The TurboPixels algorithm
TurboPixels [@levinshtein2009] is an approach based on geometric flows, that grows contours---level sets of a smooth function $\vec{\Psi} : \R^2 \times [0, \tau) \to \R^2$--- from a grid of initial seeds, which are evolved according to the equation 

$$
\Psi_t = -v \norm{\nabla \Psi}_2
$$
where $\Psi_t$ is the time derivative of $\Psi$ and the speed $v$ describes the future evolution of the contour. In practice, $\Psi$ is set to be the signed euclidean distance of each pixel to the contour, though other formulations are possible [@levinshtein2009]. 

The evolution of the level sets is discretised using 
$$\Psi^{(T+1)} = \Psi^{(T)} - v_I v_B \norm{\nabla \Psi^{(T)}} \Delta t,$$
where the product of two speeds $v_I v_B$ (where $v_I$ depends on the image content, drawing superpixel edges to edges in the image, and $v_B$ prevents superpixel overlaps) is the most important part of the algorithm.

Turbopixels produces superpixels that are compact and uniform, but often at the expense of minimising reconstruction error and maximising edge adherence. This can be rectified by running the algorithm with a higher number of target superpixels. This increase actually does not make a signficant difference to runtime, which like SLIC and LSC has linear time complexity $O(n)$ in the number of pixels. However, in practice its runtime is around 45 seconds for 150k-pixel images, so it is not useable in many applications. -->

### Other region-based algorithms

A couple of sentences on:

 - TurboPixels [@levinshtein2009] is an approach based on geometric flows, that grows contours---level sets of a smooth function $\vec{\Psi} : \R^2 \times [0, \tau) \to \R^2$--- from a grid of initial seeds
 - Quickshift
 - CRS
 - TPS


