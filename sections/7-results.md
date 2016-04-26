# Evaluation and discussion
\label{ch:results}

Superpixels from different algorithms were often visually compared by their boundary graphs. The actual input for a higher level algorithm is typically a superpixel mesh with a best color for each superpixel, e.g. the mean color or the best linear/quadratic fit as in [Fig.8, @levinshtein2009].
This justifies our use of the reconstructed image for qualitative comparison, with the additional advantage that the original image not being occluded by superpixel edges.
This also justifies our focus (as explained in section~\ref{sec:probdef}) on minimising reconstruction error as the key objective measure.

The main practical achievements revealed by our evaluation in Fig.~\ref{fig:reconstruction-error} are a significantly better reconstruction error than CtF, SLIC and SEEDS, and a significant reduction in the number of moves made in the coarse-to-fine optimisation as compared to original CtF. The qualitative comparison reinforces this conclusion, showing that image details are better reflected by iCtF superpixels than all of the other algorithms.

We first give details of the methodology for our evaluation, then show our results, first qualitatively by comparing outputs and then quantitatively using the results of running our benchmarking suite.

## Methodology for evaluating our contributions

\label{sec:method}

We had two goals in our experimentation:

1. Evaluate the claims of @yao2015 that CtF outperforms SLIC and SEEDS by independently reproducing their results using our own benchmarking implementation; 
2. Evaluate the improvements of iCtF compared to CtF, and compared too with SLIC and SEEDS for context.

We therefore followed CtF in focusing on SLIC and SEEDS for our comparisons, the two most prominent $O(n)$ algorithms capable of near-realtime performance. 

### Parameters for each algorithm

All the algorithms we are evaluating take some mandatory or optional parameters in addition to the target number of superpixels, which we chose as follows.

#### SLIC

SLIC's only additional parameter is $m$, which controls the compactness of the output superpixels (see \ref{sec:rev:slic:compactness}, p. \pageref{sec:rev:slic:compactness}). We follow @achanta2012 in setting this to 10, which provides a good balance between boundary recall and undersegmentation error. 

#### SEEDS

SEEDS, in contrast, has many parameters, such as number of bins, inclusion of a smoothing term, and number of iterations. Unfortunately, @yao2015 does not give the details of their experimental procedure, so we assumed the default, as due to time constraints we were not able to explore the parameter space to find the best parameters. Furthermore, both of the most widely available implementations of SEEDS make it very hard to control the target number of superpixels, so the results in the proceeding section only go up to 600 superpixels for SEEDS.

#### CtF

We use the same parameters as used in @yao2015 to report results, where the regularisation and boundary terms are switched off along with the minimum size constraint.

#### iCtF

All parameters are default for the initialisation process, and as for CtF we only use the colour term in the energy function. 

### Experimental procedure

We ran each algorithm on all 500 images for target outputs of up to 1300 superpixels, storing the CPU time and the output segmentation. We ran the benchmarking suite on the set of output segmentations; for each image, storing the result of the best-performing ground-truth for each metric. We also stored outputs and reconstructed images coloured with the mean of each superpixel for a set of images whose results were particularly interesting, for the purposes of visual comparison. All algorithms and benchmarks were executed on a high-performance Amazon EC2 cloud compute server using the best-performing processors available on the platform\footnote{The particular instance type was c4.xlarge, which utilises 4 CPU cores of 2.9GHz Intel Xeon E5-2666 v3 (Haswell) processors. See \url{https://aws.amazon.com/ec2/instance-types/\#compute-optimized} for more details.}.

The implementations used were:

- SLIC: author implementation from http://ivrlwww.epfl.ch/supplementary_material/RK_SLICSuperpixels.
- SEEDS: OpenCV implementation from http://docs.opencv.org/3.0-beta/modules/ximgproc/doc/superpixels.html
- CtF: C++ reimplementation available at https://github.com/donaldharvey/ictf, see \ref{sec:ctf:ownimpl}, page \pageref{sec:ctf:ownimpl}
- iCtF: available at https://github.com/donaldharvey/ictf

## Qualitative comparison of algorithm outputs

Comparing outputs on the BSDS500 in the following figures, all with target $k = 200$ superpixels, we make the following observations:

- While SLIC produces compact, regularly-shaped superpixels, the edge adherence for $k = 200$ superpixels is poor. SEEDS has better edge adherence but produces considerably less regular superpixels.
- With the shape regularisation and boundary length terms turned off, CtF consistently outperforms SLIC and SEEDS in edge adherence, and improved feature reconstruction (for instance, the individual circles in Fig.~\ref{fig:} and the clearly-defined wings of both birds in Fig.~\ref{fig:})
- iCtF provides an incremental but significant improvement over CtF, particularly noticeable in the recovery of small details in each image (the brighter horn and darker ears in Fig.~\ref{fig:}, the clearer recovery of the aerial antenna and doors in Fig.~\ref{fig:}, and the better recovery of the eyes and tail in Fig.~\ref{fig:}).
- Both iCtF and CtF superpixels are quite irregular in both shape and size. However, this irregularity is consistently based on actual image features. In SEEDS there is no clear link between the large-scale arrangement of superpixels and image feaures. 
- Both iCtF and CtF contain runs of superpixels 1 pixel in width, which are not justfied by the image content (see XX, XX). This is due to the local-connectivity preservation described in section~\ref{sec:ctf:local-connectivty}.

## Quantitative evaluation using our benchmarking library

\missingfigure{All graphs!}

## Discussion


