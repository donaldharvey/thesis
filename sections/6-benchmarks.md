# Benchmarks: how superpixel segmentation is evaluated
\label{ch:bench}

Evaluating the quality of a superpixel segmentation can be a somewhat difficult task. There is no obvious objective ideal segmentation, and indeed there are many visual scenes that the human visual system cannot consistently group. While quantitative measures are available for evaluating superpixel segmentation, it has not so far been possible to find a set of measures that accounts for all possible issues that a segmentation may possess. For instance, a segmentation may perform well on the benchmarks, but may have arbitrarily-shaped or blocky regions that are only obvious on examining the segmentation by eye.

The most commonly used evaluation methodology amongst prior work in superpixel segmentation is comparison with human-created ground truth segmentations. Specifically, the BSD, explained below, is used in almost all recent work. However, there are a few other objective metrics that are not dependent on a human-created ground truth. In addition, the runtime of outputs is important. 

A significant goal of this project was developing a robust experimental apparatus that would enable fast and consistent evaluation of superpixel segmentation, and would be reuseable for any future work on superpixel segmentation. The majority of past authors have either not released the benchmarking code used to test their algorithms, or if it has been released the code has been ad-hoc. \todo{Is this actually true?} To facilitate consistent evaluation of superpixel segmentation, we have written a high-performance C++ program based on the OpenCV toolkit [@opencv] that has been utilised by several projects including our own, and we hope will be utilised by authors in the future. 

We conclude this chapter by detailing the experimental procedure used to evaluate our work.


## The Berkeley Segmentation Dataset

\label{sec:bsd}

The Berkeley Segmentation Dataset was first introduced in [@martin2001] and extended in [@arbelaez2011]. Prior to its introduction, most segmentation algorithms were either evaluated on a few images qualitatively, or in the context of a particular task (e.g., how well the object recognition using the segmentation algorithm performs). \todo{mention ubiquity} The first, referred to as BSDS300, comprises 300 images split up into a training set of 200 images and a test set of 100 images. The second, BSDS500, adds 200 additional images forming a new test set while the old test set is used as validation set instead. For each image, a set of at least 5 ground-truth segmentations produced by different human subjects is created. 

\missingfigure{Example of image and ground-truth segmentations}

As can be seen in Fig. \ref{fig:groundtruth-examples}, the ground-truth segmentations for a single image are highly variable, reflecting the lack of a singular ideal for segmentation algorithms. This results in a fairer evaluation of superpixel segmentation algorithms, as for each segmentation a suitable ground truth can be selected, or the average performance across all ground-truths can be computed.

As well as the datasets, both the BSDS500 and BSDS300 provide (differing) sets of MATLAB benchmark code based on metrics intended for evaluating general segmentation algorithms. Unfortunately, these are unsuited to measuring superpixel segmentation quality, so authors typically use a different set of metrics. We define some of these metrics below.

## Boundary recall

For a superpixel segmentation $S$ and corresponding ground-truth segmentation $G$, we define a set of True Positives $TP(S,G)$ as the set of boundary pixels in $G$ for which there is a boundary pixel in $S$ within the range $\varepsilon$, and similarly a set of False Negatives $FN(S,G)$ as the boundary pixels in $G$ for which there is no boundary pixel in $S$ within the range $\varepsilon$. A typical value for $\varepsilon$ is 2.

Then the boundary recall $BR(\varepsilon)$ of $S$ compared with $G$ is the fraction of boundary pixels from the original segmentation that are reproduced in the output image:

$$
\mathrm{BR}(\varepsilon, S, G) = \frac{\abs{TP(S,G)}}{\abs{TP(S,G)} + \abs{FN(S,G)}}
$$

The definition of boundary pixels is given in Appendix \ref{sec:boundary-matrix}, page~\pageref{sec:boundary-matrix}.

## Undersegmentation error

The undersegmentation error measures the extent to which superpixels flood over ground truth edges, and was initially defined by @levinshtein2009 as 

$$
\mathrm{UE}(S,G) = \frac1n \sum_{G_i \in G} \left( \sum_{S_j \cap G_i \neq \emptyset} \abs{S_i - G_j} \right)
$$

However, @achanta2012 and @neubert2012 both note that this particular definition has a disadvantage, in that a superpixel that covers one ground truth segment perfectly except for a few pixels is penalised heavily.

For this reason, we elect not to use this formulation, and use two alternative definitions of undersegmentation error that have since been proposed. 

### Symmetric undersegmentation error

@neubert2012, p. 209, introduces a different formulation that we call SUE (Symmetric Undersegmentation Error):

$$
\mathrm{SUE}(S,G) = \frac1n \sum_{G_i \in G} \left( \sum_{S_j \cap G_i \neq \emptyset} \min\{ \abs{S_j \cap G_i}, \abs{S_j - G_i} \} \right),
$$

where, for each superpixel, only the smaller error introduced by either appending the flood area to the segment or by removing the overlap area from the segment is used.

### Corrected undersegmentation error

An alternative formulation is provided by @vandenbergh2012, which we refer to as CUE (Corrected Undersegmentation Error), is given by

$$
\mathrm{CUE}(S,G) = \frac1n \sum_{S_i \in S} \abs{S_i - G_{\max}(S_i)},
$$
where $G_{\max}(S_i)$ is the ground truth segment having the largest overlap with $S_i$.

\todo{Is one better? Consensus? Why/why not?}

## Achievable segmentation accuracy

When superpixels are used for pre-processing, particularly for general object segmentation, it is important that the accuracy of further processing is as far as possible unaffected. ASA (Achievable Segmentation Accuracy) represents an upper bound on the accuracy of subsequent processing, and is defined as 

$$
\mathrm{ASA}(S,G) = \frac1n \sum_{S_i \in S} \max_{G_i} \{ \abs{ S_j \cap G_i } \}
$$

## Reconstruction error

The reconstruction error as defined in \ref{ctf:energy:col} can also be used as a benchmark. Here as in the original definition we measure the colour distances in CIELAB 

$$
\mathrm{RE}(S) = \sum_p \left( I(p) - \mathrm{col}(s(p)) \right)^2
$$

Here for ease of interpretation we define a derived measure $nRMS$, which is simply the standard Root Mean Square of the colour deviations, which is then normalised to report as a percentage. $3n$ is used as there are $3n$ terms in the sum (one per channel for each pixel), and the factor 255 is used because OpenCV's CIELAB transform outputs each channel in the range [0, 255].}

$$
\mathrm{nRMS}(S) = \sqrt{\frac{\mathrm{RE}(S)}{3n}} \times \frac{1}{255} \times 100\%
$$

## Compactness

@schick2012 proposes a compactness measure for superpixels based on the isoperimetric quotient, which is defined for a region $R$ as 
$$
Q(R) = 4 \pi \times \frac{\mathrm{area}(R)}{(\mathrm{perimeter}(R))^2},
$$
which reaches 1 iff the region is exactly circular.

The compactness measure is then the weighted sum of isoperimetric quotients, provided that superpixels are connected components,
$$
\mathrm{CM}(S) = \sum_{S_i \in S} \frac{\abs{S_i}}{n} Q(S_i),
$$
and represents the extent of the superpixels' spatial coherence.


## Runtime

Runtime is a crucial property of superpixel segmentation algorithms for many applications, as identified in section \ref{itm:fast}. It is important to acknowledge that the runtime is highly dependent on the hardware and configuration of the computer on which the algorithm runs, so that results are not directly transferable to other configurations. However, on most modern hardware results are unlikely to differ beyond one order of magnitude from those given.

A further important distinction should be made between **clock time**, which is simply a measure of the amount of real time that has passed between the beginning and end of the segmentation algorithm running, and **CPU time**, which refers to the amount of time that the CPU spends on that particular process. Any modern operating system has a scheduler which switches the CPU between tasks during operation to give the illusion of parallelism. Therefore, the time that a CPU spends on a task may be different to the clock time if the CPU switches between processes during the execution of the algorithm.

## Benchmarking implementation

Whilst there are some openly-available superpixel benchmark programs available [@stutz2015, @neubert2012], their performance is insufficient for fast experimentation, in part as they are written in MATLAB. Early on in the project I was tasked with writing a fast, robust implementation of the above measures that could be used by my advisor and others in my group to evaluate their own approaches to segmentation and other related problems to which certain metrics are also applicable. I produced a high-performance C++ library based on the OpenCV toolkit [@opencv] to produce the metrics for a given superpixel segmentation and BSD500 image--ground-truth pair, along with Python code to run these benchmarks in parallel for all 500 images and analyse and graph the results. 

\toadd{Paragraph about intersection metrics being the main performance issue and how I solved.}
