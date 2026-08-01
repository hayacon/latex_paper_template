%% manuscript.cls
%% A journal-agnostic paper class for drafting and preprint publication.
%%
%% Copyright (C) 2026 Hayato Ishida
%%
%% This work may be distributed and/or modified under the conditions of
%% the LaTeX Project Public License, either version 1.3c of this license
%% or (at your option) any later version. The latest version of this
%% license is in
%%     https://www.latex-project.org/lppl.txt
%% and version 1.3c or later is part of all distributions of LaTeX
%% version 2008 or later.
%%
%% This work has the LPPL maintenance status "maintained".
%% The Current Maintainer of this work is Hayato Ishida.
%% This work consists of the files manuscript.cls and review-form.tex.
%%
%% Usage:
%%   \documentclass[draft,twocolumn]{manuscript}     % marked-up drafting copy
%%   \documentclass[preprint,twocolumn]{manuscript}  % clean preprint / arXiv
%%   \documentclass[draft,onecolumn]{manuscript}
%%   \documentclass[preprint,onecolumn]{manuscript}
%%
%% The abstract is always set full width, in both column modes.

\NeedsTeXFormat{LaTeX2e}[2020/10/01]
\ProvidesClass{manuscript}[2026/08/01 v1.0 Journal-agnostic draft/preprint paper class]

%% ---------------------------------------------------------------------------
%% Class options
%% ---------------------------------------------------------------------------

\newif\ifms@draft   \ms@draftfalse
\newif\ifms@two     \ms@twotrue

\def\ms@ptsize{10pt}
\def\ms@paper{a4paper}

% mode: draft (== review) vs preprint (== final)
\DeclareOption{draft}{\ms@drafttrue}
\DeclareOption{review}{\ms@drafttrue}
\DeclareOption{preprint}{\ms@draftfalse}
\DeclareOption{final}{\ms@draftfalse}

% column model
\DeclareOption{onecolumn}{\ms@twofalse}
\DeclareOption{twocolumn}{\ms@twotrue}

% body size
\DeclareOption{10pt}{\def\ms@ptsize{10pt}}
\DeclareOption{11pt}{\def\ms@ptsize{11pt}}
\DeclareOption{12pt}{\def\ms@ptsize{12pt}}

% paper size
\DeclareOption{a4paper}{\def\ms@paper{a4paper}}
\DeclareOption{letterpaper}{\def\ms@paper{letterpaper}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

% Every option given to \documentclass stays in \@classoptionslist and is
% offered to every package loaded afterwards. LaTeX's own `draft' means
% something quite different there: graphicx replaces images with empty
% boxes, hyperref kills the links, microtype switches itself off. Strip it
% from the global list so that our `draft' means only what this class says
% it means.
\ifms@draft
  \def\ms@newopts{}%
  \@for\ms@opt:=\@classoptionslist\do{%
    \def\ms@draftword{draft}%
    \ifx\ms@opt\ms@draftword
    \else
      \edef\ms@newopts{\ifx\ms@newopts\@empty\else\ms@newopts,\fi\ms@opt}%
    \fi
  }%
  \let\@classoptionslist\ms@newopts
\fi

\ifms@two\PassOptionsToClass{twocolumn}{article}\fi
\LoadClass[\ms@ptsize,\ms@paper]{article}

%% ---------------------------------------------------------------------------
%% Page geometry
%% ---------------------------------------------------------------------------

\RequirePackage{geometry}
\ifms@two
  \geometry{\ms@paper,top=2.2cm,bottom=2.4cm,left=1.9cm,right=1.9cm}
  \setlength{\columnsep}{7mm}
\else
  \geometry{\ms@paper,top=2.5cm,bottom=2.7cm,left=3.4cm,right=3.4cm}
\fi

%% ---------------------------------------------------------------------------
%% Fonts and general typography
%% ---------------------------------------------------------------------------

\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
% Times, via newtx. Under pdflatex the actual Monotype Times New Roman is
% not available, so this uses TeX Gyre Termes, which is metrically
% compatible with it and is the standard substitute. Helvetica is the
% usual sans companion, scaled down because it runs large beside Times.
% newtxmath has to come after amsmath, so it is loaded further down.
\RequirePackage{newtxtext}
\RequirePackage[scaled=0.92]{helvet}
\RequirePackage{microtype}
\RequirePackage{xcolor}
\RequirePackage[final]{graphicx}
\RequirePackage{amsmath,amssymb}
% Must follow amsmath. Supplies Times-matching maths, so no Computer
% Modern is left anywhere in the output.
\RequirePackage{newtxmath}
\RequirePackage{enumitem}
\RequirePackage[skip=6pt,labelfont=bf,font=small]{caption}
\RequirePackage{subcaption}
\RequirePackage{float}
\RequirePackage{wrapfig}

% Tables
\RequirePackage{booktabs}
\RequirePackage{tabularx}
\RequirePackage{multirow}
\RequirePackage{makecell}
\RequirePackage{longtable}
\RequirePackage{threeparttable}
\RequirePackage{adjustbox}
\RequirePackage{siunitx}
% per-mode=symbol writes "kbit/s" rather than "kbit s^-1". Besides reading
% better in prose, it avoids a superscript that siunitx sets in a 7pt
% Computer Modern, which is the one place Times does not reach.
\sisetup{detect-all,table-align-text-post=false,per-mode=symbol}

% Slightly airier rows, and ragged variants of tabularx's X column.
\renewcommand{\arraystretch}{1.15}
\newcolumntype{L}{>{\raggedright\arraybackslash}X}
\newcolumntype{R}{>{\raggedleft\arraybackslash}X}
\newcolumntype{C}{>{\centering\arraybackslash}X}

% Where figures live, so \includegraphics needs only the file name.
\graphicspath{{figures/}{./}}

\definecolor{msgrey}{gray}{0.45}
\definecolor{mslink}{RGB}{0,74,133}

\setlength{\parindent}{1.2em}
\setlength{\emergencystretch}{2em}
\widowpenalty=10000
\clubpenalty=10000

%% ---------------------------------------------------------------------------
%% ISO date, used by the draft footer and title block
%% ---------------------------------------------------------------------------

\def\ms@twodigits#1{\ifnum#1<10 0\fi\number#1}
\def\ms@isodate{\number\year-\ms@twodigits\month-\ms@twodigits\day}

%% ---------------------------------------------------------------------------
%% Title-block metadata
%% ---------------------------------------------------------------------------

\def\ms@title{\@latex@warning@no@line{No \noexpand\title given}}
\def\ms@author{}
\def\ms@affiliation{}
\def\ms@email{}
\def\ms@keywords{}
\def\ms@version{}
\def\ms@thanksnote{}

\renewcommand\title[1]{\gdef\ms@title{#1}}
\renewcommand\author[1]{\gdef\ms@author{#1}}
\newcommand\affiliation[1]{\gdef\ms@affiliation{#1}}
\newcommand\email[1]{\gdef\ms@email{#1}}
\newcommand\keywords[1]{\gdef\ms@keywords{#1}}
\newcommand\version[1]{\gdef\ms@version{#1}}
\newcommand\thanksnote[1]{\gdef\ms@thanksnote{#1}}

%% ---------------------------------------------------------------------------
%% Abstract: captured here, emitted full width by \maketitle
%% ---------------------------------------------------------------------------

\newsavebox\ms@absbox
\newif\ifms@hasabs \ms@hasabsfalse
\newlength\ms@abshang
\setlength\ms@abshang{0.06\textwidth}

\renewenvironment{abstract}{%
  \global\ms@hasabstrue
  \begin{lrbox}{\ms@absbox}%
  \begin{minipage}{\dimexpr\textwidth-2\ms@abshang\relax}%
    \small
    \noindent\textbf{\abstractname}\quad\ignorespaces
}{%
  \par
  \end{minipage}%
  \end{lrbox}%
  % lrbox assigns locally, and the environment group would discard it.
  \global\setbox\ms@absbox=\box\ms@absbox
}

%% ---------------------------------------------------------------------------
%% \maketitle
%% ---------------------------------------------------------------------------

\def\ms@titleblock{%
  \begin{center}
    {\LARGE\bfseries\ms@title\par}%
    \vspace{1.1em}%
    {\large\ms@author\par}%
    \ifx\ms@affiliation\@empty\else
      \vspace{0.45em}{\normalsize\ms@affiliation\par}%
    \fi
    \ifx\ms@email\@empty\else
      \vspace{0.3em}{\normalsize\texttt{\ms@email}\par}%
    \fi
    \ifms@draft
      \vspace{0.6em}%
      {\small\itshape\color{msgrey}%
        Draft compiled \ms@isodate
        \ifx\ms@version\@empty\else\ \textbullet\ \ms@version\fi
        \@ifundefined{ms@wc@total}{}{\ \textbullet\ \csname ms@wc@total\endcsname\ words}%
      \par}%
    \fi
  \end{center}
  \vspace{0.9em}%
  \ifms@hasabs
    \centerline{\usebox\ms@absbox}%
    \vspace{0.7em}%
  \fi
  \ifx\ms@keywords\@empty\else
    \centerline{\begin{minipage}{\dimexpr\textwidth-2\ms@abshang\relax}%
      \small\noindent\textbf{Keywords}\quad\ms@keywords\par
    \end{minipage}}%
  \fi
  \vspace{1.8em}%
}

\renewcommand\maketitle{%
  \ifms@two
    \twocolumn[\ms@titleblock]%
  \else
    \ms@titleblock
    % Stop a later [t] float from migrating above the title block.
    \suppressfloats[t]%
  \fi
  \ifx\ms@thanksnote\@empty\else
    \begingroup
      \renewcommand\thefootnote{}%
      \footnotetext{\ms@thanksnote}%
      \addtocounter{footnote}{-1}%
    \endgroup
  \fi
  \thispagestyle{msmain}%
  \ifms@draft\linenumbers\fi
  % Header line for the review form.
  \if@filesw
    \protected@write\ms@rvwfile{\let\\\space\let\label\relax}%
      {\string\rvwmeta{\ms@title}{\ms@version}{\ms@isodate}%
       {\ifms@draft draft\else preprint\fi\ifms@two, two-column\else, one-column\fi}%
       \@percentchar}%
  \fi
}

%% ---------------------------------------------------------------------------
%% Section headings, with optional draft word-count tags
%% ---------------------------------------------------------------------------

\RequirePackage[explicit]{titlesec}

% Word counts are read from <jobname>.wcnt, written by wordcount.py.
% Each entry is \mswc{<n>}{<count>}, n counting section commands in source order.
\def\mswc#1#2{\expandafter\gdef\csname ms@wc@#1\endcsname{#2}}
\AtBeginDocument{\IfFileExists{\jobname.wcnt}{\input{\jobname.wcnt}}{}}

\newcounter{mssec}

% Every section heading is recorded to <jobname>.rvw, so review-form.tex
% can build a form listing the paper's real sections and their pages.
% This is written whatever the mode, and is independent of whether the
% document prints a table of contents.
\newwrite\ms@rvwfile
\AtBeginDocument{\if@filesw\immediate\openout\ms@rvwfile=\jobname.rvw\relax\fi}

% titlesec runs the same before-code for \section and \section*, and gives
% no way to tell them apart. A numbered heading always advances
% \thesection, so a heading that leaves it unchanged must be starred.
\def\ms@lastnum{0}

% Suppress the next heading's record. The bibliography heading is not a
% section of the paper anyone reviews, so it is left off the form.
\newif\ifms@norecord
\newcommand{\nosectionrecord}{\global\ms@norecordtrue}
\AtBeginDocument{%
  \let\ms@origthebibliography\thebibliography
  \renewcommand{\thebibliography}[1]{%
    \nosectionrecord\ms@origthebibliography{#1}%
  }%
}

\def\ms@sechook#1{%
  \stepcounter{mssec}%
  \edef\ms@thisnum{\thesection}%
  \ifx\ms@thisnum\ms@lastnum
    \let\ms@num\@empty
  \else
    \let\ms@num\ms@thisnum
    \global\let\ms@lastnum\ms@thisnum
  \fi
  \ifms@norecord
    \global\ms@norecordfalse
  \else
    \ms@writerecord{#1}%
  \fi
  \ifms@draft
    \@ifundefined{ms@wc@\themssec}{}{%
      \nobreak\hspace{0.6em}%
      % \mbox so a long heading cannot break the tag into "[4147" / "words]".
      \mbox{\normalfont\footnotesize\color{msgrey}%
        [\csname ms@wc@\themssec\endcsname\ words]}%
    }%
  \fi
}

\def\ms@writerecord#1{%
  \if@filesw
    \edef\ms@rvwfixed{{\themssec}{\ms@num}}%
    % \thebibliography passes \@mkboth inside the heading argument, and
    % titlesec wraps it in \ttl@gmk. Neither belongs in the record.
    \protected@write\ms@rvwfile{%
      \let\label\relax \let\index\relax
      \let\ttl@gmk\@gobble \let\@mkboth\@gobbletwo \let\\\space
    % The trailing percent comments out the newline. Without it each line
    % of the file yields a space token, and a space between two rows of a
    % table opens a row of its own before \rowcolor can be applied.
    }{\string\rvwsection\ms@rvwfixed{#1}{\thepage}\@percentchar}%
  \fi
}

\titleformat{\section}[block]
  {\normalfont\large\bfseries}{\thesection}{0.7em}{#1\ms@sechook{#1}}
\titleformat{\subsection}[block]
  {\normalfont\normalsize\bfseries}{\thesubsection}{0.6em}{#1}
\titleformat{\subsubsection}[block]
  {\normalfont\normalsize\itshape}{\thesubsubsection}{0.6em}{#1}

\titlespacing*{\section}{0pt}{1.6ex plus .8ex minus .2ex}{0.9ex plus .2ex}
\titlespacing*{\subsection}{0pt}{1.3ex plus .6ex minus .2ex}{0.7ex plus .2ex}
\titlespacing*{\subsubsection}{0pt}{1.1ex plus .5ex minus .2ex}{0.6ex plus .2ex}

%% ---------------------------------------------------------------------------
%% Running foot
%% ---------------------------------------------------------------------------

\RequirePackage{fancyhdr}
\fancypagestyle{msmain}{%
  \fancyhf{}%
  \renewcommand\headrulewidth{0pt}%
  \renewcommand\footrulewidth{0pt}%
  \ifms@draft
    \fancyfoot[L]{\footnotesize\color{msgrey}DRAFT}%
    \fancyfoot[C]{\footnotesize\thepage}%
    \fancyfoot[R]{\footnotesize\color{msgrey}%
      \ms@isodate
      \ifx\ms@version\@empty\else\ \textbullet\ \ms@version\fi}%
  \else
    \fancyfoot[C]{\footnotesize\thepage}%
  \fi
}
\pagestyle{msmain}

%% ---------------------------------------------------------------------------
%% Draft-only apparatus: watermark and line numbers
%% ---------------------------------------------------------------------------

\ifms@draft
  \RequirePackage{eso-pic}
  \AddToShipoutPictureBG{%
    \AtTextCenter{%
      \makebox(0,0)[c]{%
        \rotatebox{55}{%
          \color{black!7}\fontsize{6cm}{6cm}\selectfont\bfseries DRAFT}}}%
  }

  \ifms@two
    \RequirePackage[switch,mathlines]{lineno}
  \else
    \RequirePackage[left,mathlines]{lineno}
  \fi
  \renewcommand\linenumberfont{\normalfont\tiny\sffamily\color{msgrey}}
  \setlength\linenumbersep{1.2em}

  % Keep line numbering running through amsmath display environments.
  \newcommand*\ms@patchamsmath[1]{%
    \expandafter\let\csname ms@old#1\expandafter\endcsname\csname #1\endcsname
    \expandafter\let\csname ms@oldend#1\expandafter\endcsname\csname end#1\endcsname
    \renewenvironment{#1}%
      {\linenomath\csname ms@old#1\endcsname}%
      {\csname ms@oldend#1\endcsname\endlinenomath}%
  }
  \newcommand*\ms@patchamsmathstar[1]{%
    \ms@patchamsmath{#1}%
    \ms@patchamsmath{#1*}%
  }
  \AtBeginDocument{%
    \ms@patchamsmathstar{equation}%
    \ms@patchamsmathstar{align}%
    \ms@patchamsmathstar{gather}%
    \ms@patchamsmathstar{flalign}%
    \ms@patchamsmathstar{multline}%
  }
\fi

%% ---------------------------------------------------------------------------
%% References
%% ---------------------------------------------------------------------------

\RequirePackage[numbers,sort&compress,square]{natbib}
\setlength{\bibsep}{2pt plus 1pt}
\renewcommand{\bibfont}{\small}

%% ---------------------------------------------------------------------------
%% hyperref last
%% ---------------------------------------------------------------------------

\RequirePackage{hyperref}
\hypersetup{
  colorlinks=true,
  linkcolor=mslink,
  citecolor=mslink,
  urlcolor=mslink,
  breaklinks=true,
  pdfborder={0 0 0}
}
\RequirePackage{cleveref}

\endinput
