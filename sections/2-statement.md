# Problem statement

\label{ch:probdef}

In this chapter we formally introduce important terms and some notation used throughout the report, before stating the problem of superpixel segmentation.

## Notation and definitions used throughout this report

- We denote the cardinality of a set $A$ using the notation $\abs{A}$.
- We denote the Euclidean norm $\norm{(x,y)} = \sqrt{x^2 + y^2}$
- For $x \in \R$, $\floor{x}$ and $\ceil{x}$ round $x$ down and up respectively to the nearest integer.
- We use $\N$ to mean the set of natural numbers $\{1, 2, \dots \}$ not including zero.
- For points $p \in \R^n$, we sometimes use the notation $p^2$ to mean the componentwise square $(p_1^2, \dots, p_n^2)$.

\begin{defn}[Pixel grids]
A \textbf{pixel grid} is a rectangular grid of $n \in \N$ points, having width $w \in \N$ and height $h \in \N$ such that $w \times h = n$.

$$
W \times H = \{1, \dots, w\} \times \{1, \dots, h\}.
$$

A \textbf{pixel} is simply a point $p = (i, j) \in W \times H$.
\end{defn}

\smallskip

\begin{defn}[Colour space]
A \textbf{colour space} is a set $C$ of possible colour values.
\end{defn}

\smallskip

\begin{examples}[Examples of colour spaces]\end{examples}
\begin{itemize}

\item Greyscale images can be represented by $C_\mathrm{G} = \{0, \dots, 255\}$, where each possible intensity fits into a single byte.

\item RGB space is the set $C_\mathrm{RGB} = \{(r,g,b) \mid r,g,b \in \{0, \dots, 255\}\}$ that treats colours as combinations of red, green and blue light. Each colour $c \in C_\mathrm{RGB}$ is a combination of three "channels" measuring the intensity of red, green and blue light respectively. 

\item HSV space is the set $C_\mathrm{HSV} = \{(h,s,v) \mid h \in [0, 2\pi), s, v \in [0, 1]\}$. HSV treats colours as a hue (the base colour), saturation (the "colourfulness"), and value (the brightness).

\end{itemize}

\smallskip

\begin{defn}[Images]
An \textbf{image} $I$ is a map from a pixel grid to a colour space:

$$
I = W \times H \to C
$$
\end{defn}

\smallskip

\begin{defn}[Mean colour]
The mean colour $\mcol(R)$ of a set of pixels $R$ is

$$\mcol(R) = \frac{1}{|R|} \sum_{p \in R} I(p)$$
\end{defn}

\smallskip

\begin{defn}[Neighbourhoods]
Let $p = (x, y) \in W \times H$ be a pixel in a pixel grid.

The \textbf{4-neighbourhood} of a pixel, $\mathcal{N}_4(p)$, is the set of pixels in each of the four cardinal directions, i.e., $\mathcal{N}_4(p) = \{ (x+1, y), (x, y-1), (x-1,y), (x, y+1) \}$.

\smallskip

The \textbf{8-neighbourhood} $\mathcal{N}_8(p)$ is the union of the 4-neighbourhood of $p$ with its four diagonal neighbours:

$$\mathcal{N}_8(p) = \mathcal{N}_4(p) \cup \{ (x+1, y-1), (x-1, y-1), (x-1, y+1), (x+1, y+1) \}$$
\end{defn}

\smallskip

\begin{defn}[Graph]
A graph is an ordered pair $G = (V, E)$ where $V$ is a set of vertices and $E$ is a set of unordered pairs of vertices $(a, b)$ with $a,b \in V$. 
\end{defn}

\begin{defn}[Pixel grids as graphs]
The \textbf{4-neighbourhood graph} of a pixel grid $G_4(W \times H)$ is given by $(W \times H, E)$ where $W \times H$ where pixels are vertices and each pixel is connected to its 4 neighbours $E = \{ (p_1, p_2) \mid p_1, p_2 \in V; p_1 \in \mathcal{N}_4(p_2) \}$.

The \textbf{8-neighbourhood graph} $G_8(W \times H)$ is defined similarly, with the same vertices and $mathcal{N}_8$ replacing $mathcal{N}_4$ in the edge definition.
\end{defn}

\smallskip

\begin{defn}[Subgraph]
A graph $H = (V_H, E_H)$ is called a subgraph of a graph $G = (V, E)$ if $V_H \subseteq V$ and $E_H \subseteq E$. 
\end{defn}

\begin{defn}[Path]
A path between two vertices of a graph is a sequence of its edges joining a set of distinct vertices where all edges are also distinct.
\end{defn} 

\begin{defn}[Connected component]
A \textbf{connected component} of a graph $G$ is a subgraph $H$ where every vertex in $H$ is connected to every other vertex in $H$ by a path. 
\end{defn}

\smallskip

\begin{defn}[Partition]
A partition of a set $X$ is a set $P$ of subsets of $X$, where:
\begin{enumerate}[label=\emph{\alph*)}]
\item $\displaystyle \emptyset \not\in P$
\item $\displaystyle \bigcup_{A \in P} A = X$
\item $\displaystyle A, B \in P \;\mathrm{and}\; A \neq B \implies A \cap B = \emptyset$.
\end{enumerate}
\end{defn}

\smallskip

\begin{defn}[Superpixel] A superpixel $S_x$ of a pixel grid $W \times H$ is a set of pixels that forms a connected component over the four-neighbourhood graph of $W \times H$.
\end{defn}

\smallskip

\label{probdef}

\begin{defn}[Superpixel segmentation]
A \textbf{superpixel segmentation} of an image $I : W \times H \to C$ is a set of superpixels

\begin{equation}
S = \{S_1, \dots, S_k\} \enspace \textrm{with} \enspace S_i \subset W \times H
\end{equation}

where $S$ forms a partition over the pixels $W \times H$.

The associated \textbf{superpixel map} is a map $s: W \times H \to S$ as giving the superpixel $s(p)$ of which a pixel $p \in W \times H$ is a member.
\end{defn}

## Superpixel segmentation as an appropximation problem

Having provided definitions for all important terms used, we now turn to formally stating the problem of superpixel segmentatition.

\begin{defn} \label{def:re} The \textrm{reconstruction error} is defined as a sum-of-squares error measuring how well a segmentation $S$ approximates an image $I: W \times H \to C$:

$$\mathrm{RE}(S) = \sum_{p \in W \times H} (I(p) - \mcol(s(p)))^2.$$
\end{defn}

\begin{defn} The process of creating a superpixel segmentation is an approximation problem that takes an input image $I$ and returns a segmentation $S$ satisfying the following conditions:

(Objective conditions)
\begin{enumerate}[label=\emph{\alph*)}]
\item \textbf{(Complexity reduction)}
$|S| < 0.01n$, so that the resulting segmentation is less complex than the input image.

\item \textbf{(Quality of approximation)}
For a given number of superpixels $k$, $S$ should minimise the reconstruction error $RE(S)$, so that it represents the input image as accurately as possible.

\item \textbf{(Fast runtime)}
The runtime should be less than 1 sec for images up to n = 150k superpixels, and the memory use and asymptotic complexity should be linear or close to linear in $n$.
\label{itm:fast}
\end{enumerate}

(Practical considerations)
\begin{enumerate}[label=\emph{\alph*)},resume]
\item \textbf{(Quality of perceptual grouping)}
All pixels in a superpixel should belong to the same perceptual region - i.e., , so superpixels should adhere well to object boundaries (e.g. those identified by human subjects in the BSD described in section~\ref{sec:bsd}).
\item \textbf{(Uniformity)}
Superpixels should be close to uniform in size and have shapes as close as possible to a round disk without compromising the accuracy required by b) and d).
\end{enumerate}
\end{defn}

There is therefore a dual requirement of speed and accuracy, and a choice to be made regarding what to emphasise. In our considerations, we have decided to prioritise speed over maximal accuracy, as in many applications being able to run in real time is crucial. 
Furthermore, condition b) seems more important than condition d), as it is subjective and any two vision systems may differently categorise objects in a scene. 
Additionally, we choose to deprioritise condition e), so that a higher density of superpixels can be allocated to more visually complex regions.

## CIELAB: a perceptually uniform colour space

\label{cielab}

\missingfigure{Image showing difference between RGB, XYZ and CIELAB}

\toadd{Section unfinished and needs to be linked to the rest of this chapter}

In 1931, the International Commission on Illumination (CIE) defined a set of colour spaces which remain in use today [@smith1931] based on parameters derived from a series of experiments [@wright1929, @guild1932]. Their aim was to provide universal colour spaces matching the range of colours perceivable by the average human. The human eye has three types of cone cells which it uses for colour perception, with sensitivity peaks in short (420--440 nm), medium (M, 530--540 nm), and long (560–-580 nm) wavelengths. Rather than attempting to represent colours by the values needed to create colours of a certain wavelength, the CIE spaces instead base the colour spaces on **tristimulus values**, corresponding to the stimulation that a given colour produces in the short, medium and long photoreceptor types respectively. CIEXYZ space uses these values directly. The medium-type (Y) receptors have a much wider frequency response than the long- and short-type receptors, so this is also used to indicate luminance (lightness).

CIELAB space is a transformation of CIEXYZ space that attempts to be perceptually uniform, i.e. reflect human-perceived colour differences, and map to an orthogonal coordinate system of vectors $(L, a*, b*)$ where $L \in [0, 100]$ represents intensity and $a\*, b\* \in [-128, 128]$ together represent a colour. The key feature that makes it perceptually uniform is its adjustment to the eye's nonlinear response curves. This uniformity when distances are measured using the Euclidean metric on the $La\*b\*$ coordinates makes it excellent for applications that want to mimic human vision.


