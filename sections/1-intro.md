# Introduction

## Motivation for superpixels as a preprocessing step

In computing, the representation of almost all kinds of images following their capture is as a rectangular grid of square pixels, where each pixel stores the intensity at that particular $(x,y)$ coordinate in the image, in one or three channels depending on whether the image is grayscale or colour.
Many important algorithms in computer vision operate directly on this pixel grid, or on a field directly derived from it: for instance, the most influential approach to face detection [@viola-faces]; many pedestrian detection algorithms [@pedestrian-detection-review]; pose estimation [@ferrari2008] and general object detection [@schneiderman2004].

However, this is not the most natural way to represent images: it is an artefact of the capture and display methods that are currently predominant. Furthermore, it is inefficent, the rectangular pixel grid contains far more data than is necessary to understand the image. A modern camera produces images comprised of tens of millions of pixels. Furthermore, many important algorithms including those above have a runtime that at least rises proportionally the number of pixels, if not faster.

Furthermore, the most demanding tasks in computer vision, such as autonomous driving and general-purpose object recognition, require the detection of meaningful groups of regions that have similar colour, texture, shape etc in order to achieve the success rates that they require.

In human vision, evolution has produced a very fast, efficient perception process that enables scenes to be analysed on the order of milliseconds. Visual perception can broadly be split into two subprocesses. Low-level grouping involves grouping together regions based on factors such as similarity, proximity, closure, continuity, etc. (see section \ref{sec:gestalt}), and high-level grouping, where prior knowledge and experience and more advanced cues are employed to assemble the low-level groups into perceptually meaningful visual objects.

Inspired by this natural low-level grouping process, a process called **superpixel segmentation** has been introduced as a way to represent images in a less redundant form that can speed up higher-level processing. It groups visual data into perceptually meaningful, atomic regions from a pixel grid by creating a partition over the set of pixels. 

This methodology of dividing the image into superpixels as a pre-processing step was first introduced by @ren2003 and applied successfully to unsupervised image segmentation, the problem of separating an image into regions that correspond to different objects or parts of objects.

\toadd{Add this somewhere: It is important to note the distinction between general image segmentation, which simply seeks to split images into general (typically large) regions often corresponding to objects or large-scale visual structure, and superpixel segmentation, which results in a much larger set of smaller primitives based mainly on local perceptual groupings and typically numbering in the hundreds.}

Since then, superpixel segmentation has been applied successfully to numerous problems in computer vision, such as pose estimation [@mori2004], object classification [@fulkerson2009], generating simple 3D models from single images [http://dhoiem.cs.illinois.edu/projects/popup/], obstacle detection for smart driving systems [@giosan2014], and recently as part of a broader approach to determining 3D scene flow for self-driving cars [@menze2015].

\toadd{Summarise the required properties of superpixel segmentation}

## Gestalt principles of perception: the inspiration for superpixel-based approaches

\label{sec:gestalt}

\toadd{Half a page to a page about Gestalt principles of human perception. This should go into some detail about what they are, their basis, and why they have been important for superpixel segmentation}

## Main contributions of our research

It is critical that superpixel segmentation algorithms are available that are as high-performance and as accurate as possible. Above all else, this motivated my choice to investigate in detail a promising recent superpixel segmentation algorithm [@yao2015], henceforth CtF, after reviewing the field. To evaluate the extent to which CtF represented the state-of-the-art in superpixel segmentation, I developed a fast and robust benchmarking library using high-performance C++. Following this, a series of improvements to the algorithm were attempted, to which end I wrote my own implementation of the algorithm, working in tandem with Dr. Kurlin, who introduced a novel initialisation process as a route to both faster convergence and higher-quality final segmentations. We integrated this into my implementation and, using the benchmarking library, evaluated our improvements, finding that our new algorithm iCtF surpassed the quality of CtF on one key measure, the reconstruction error, as well as converging faster, performing equally well on all other metrics. We submitted this work to the proceedings of the 14th European Conference on Computer Vision [@us].

## Contents

Chapter \ref{ch:probdef} intoduces necessary notation and formally defines important terms used throughout this report, before formally stating the problem of superpixel segmentation. In Chapter \ref{ch:review}, existing approaches to superpixel segmentation are reviewed and split into three families. Chapter \ref{ch:ctf}, CtF, examins the algorithm in @ctf in detail. Chapter \ref{ch:ictf} details the adaptive initialisation process we introduce, and the modifications we make in our implementation of CtF. Chapter \ref{ch:bench} explains the various metrics used to analyse the performance of superpixel segmentation algorithms, and describes the high-performance C++ benchmarking suite written by the author to test the effectiveness of our improved algorithm, as well as our methodology for performing the evaluation. Chapter \ref{ch:results} gives the results of running this benchmarking suite, as well some example outputs. Finally, Chapter \ref{ch:conclusion} evaluates and contextualises the results, and reports the achievements of this project.

\newpage

<!-- ## Summary of approach

The above considerations have led us to a new approach to superpixel segmentation. Our key contribution to the problem is the introduction of a new adaptive initialisation phase that results in a non-uniform superpixel mesh, after which a coarse-to-fine optimisation procedure takes place, which is a slightly modified version of that described in @ctf.

**Phase 1.** _Adaptive initialisation_

**Stage 1.1.** Strong vertical and horizontal edges are detected to form an initial rectilinear grid.

**Stage 1.2.** Blocks are merged to minimise a reconstruction error to get a partition of connected rectilinear polygons, which forms the input for the next phase.

**Phase 2.** _Coarse-to-fine optimisation_

**Stage 2.1.** Blocks are split into quarters.

**Stage 2.2.** Boundary blocks are iteratively exchanged between superpixels to minimise an energy function. Once an energy minimum is reached or a threshold number of moves, this stage terminates and stage 2.1 is repeated. This continues until all blocks are 1 pixel in size. -->




