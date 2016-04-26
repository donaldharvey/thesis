# Review of past approaches to superpixel segmentation

\label{ch:review}

Since the introduction of superpixel segmentation by @ren2003 using Normalized Cuts [@shi2000], numerous algorithms have been proposed that satisfy the properties listed in \ref{probdef}. Research on superpixel algorithms has seen substantial growth since 2010, reflecting the increasing utilisation of superpixels in higher-level computer vision problems. Some approaches choose to focus on accuracy over speed; some on speed over accuracy, and some have balanced both. 

Nearly all these algorithms broadly fit into three categories. A finer-grained distinction is certainly possible, but beyond the scope of this work. In the first, the pixel grid is treated as a graph to which cuts are gradually added. In the second, superpixels are gradually grown from some initial set. In the third, some initial partitioning is gradually improved by exchanging blocks of pixels between boundaries, the granularity of which increases as the algorithm progresses.

For each family, a few influential and representative approaches are chosen to examine in some detail.

