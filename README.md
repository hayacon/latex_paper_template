# manuscript — paper template

A journal-agnostic LaTeX class for drafting and preprint publication.
Copy this whole folder to start a new paper.

## Mode switching

Everything is controlled from the `\documentclass` line in `main.tex`.

```latex
\documentclass[draft,twocolumn]{manuscript}
```

| Option group | Keywords | Default |
|---|---|---|
| Mode | `draft` (alias `review`) / `preprint` (alias `final`) | `preprint` |
| Column model | `onecolumn` / `twocolumn` | `twocolumn` |
| Body size | `10pt` / `11pt` / `12pt` | `10pt` |
| Paper | `a4paper` / `letterpaper` | `a4paper` |

The four useful combinations:

```latex
\documentclass[draft,twocolumn]{manuscript}      % marked-up drafting copy
\documentclass[draft,onecolumn]{manuscript}      % wide drafting copy
\documentclass[preprint,twocolumn]{manuscript}   % arXiv / submission
\documentclass[preprint,onecolumn]{manuscript}   % arXiv / submission, wide
```

**The abstract is always set at full text width, in both column models.**

## What `draft` adds

| Feature | Detail |
|---|---|
| Line numbers | `lineno`, running through displayed equations. Two-column mode puts numbers in the outer margin of each column; one-column mode puts them on the left. |
| DRAFT watermark | Light diagonal stamp on every page. |
| Date / version footer | `DRAFT` left, page centre, `YYYY-MM-DD • <version>` right. Also repeated under the title block. |
| Word counts | Per-section count in grey beside each heading, e.g. `[73 words]`, and a total in the title block. |

`preprint` removes all of it and leaves a plain centred page number.

## Word counts

Counts come from `wordcount.py`, which is run automatically by `latexmk`
via `latexmkrc` — no shell-escape and no `texcount` needed.

It follows `\input` and `\include`, drops comments, maths, floats, and
tabular material, then writes `main.wcnt` for the class to read.
Counts lag one pass on a first build; latexmk's rerun loop settles it.

Headings LaTeX generates for itself — the `References` heading from
`\bibliography`, and `\tableofcontents` / `\listoffigures` /
`\listoftables` — get no count, but the script still reserves an index
for each. Without that, every count after the bibliography would be
attached to the wrong heading.

Besides the per-section counts it writes three named totals:

| Key | Covers |
|---|---|
| `\mswc{abstract}` | the abstract alone, excluded from the two below |
| `\mswc{body}` | everything up to the first unnumbered section |
| `\mswc{total}` | the whole document, abstract aside |

To run it by hand:

```bash
python3 wordcount.py main.tex
```

## Review form

`review-form.tex` produces a one-page A4 sheet for marking up a printed
draft with a pen. Build the paper first, then the form:

```bash
latexmk -pdf main.tex && latexmk -pdf review-form.tex
```

It fills itself in from the paper. `manuscript.cls` writes `main.rvw` at
every section heading, recording the number, title and page; `main.wcnt`
supplies the word counts. So the form lists your actual sections, with
their real page numbers, matching the draft you just printed.

The bibliography heading is left off the list — nobody reviews it. Two
shaded totals rows are inserted automatically: **Body total** immediately
before the first unnumbered section, which is the number venues care
about, and **Total** at the very end.

The **abstract** gets a fixed row of its own at the top of the grid, ahead
of the first section. It carries four criteria rather than five, since
nothing is cited in an abstract, and **its word count is excluded from
both totals** — venues count an abstract separately and against its own
limit, so folding it into the body figure would only mislead. The count
is still shown on its own row.

Each section gets three rows. Five criteria are spread over the first
two, three then two, so each cell stays wide enough to write several line
numbers in:

| | | |
|---|---|---|
| **C/E** claim and evidence | **S/F** structure and flow | **Eng** English and phrasing |
| **Cut** cut or expand | **Cit** citation missing, weak, or not supporting the claim | |

The third row is a full-width **Notes** band with no internal rules, for
writing across. Below the grid sit an overall block and a verdict line.

Each criterion carries its own label and tick box inside the cell, rather
than being named in the header, because they no longer line up one per
column.

The form runs to as many pages as it needs. Two knobs control the writing
space: `\rvwrowheight` for each of the two criterion rows,
`\rvwnoteheight` for the notes band beneath them.

To change the criteria, edit `\rvwsection` in the grid section of
`review-form.tex` — the `\rvwcrit{...}` calls are the labels — and the
legend line above the grid. Those are the only two places they are named.

### How it is meant to be used

The paper carries **where**, the form carries **what**.

Mark the printed draft with two strokes and nothing else:

| stroke | meaning |
|---|---|
| underline | something is wrong here |
| cross line through | cut this, or say it shorter |

Then go section by section and take each criterion in turn. **Tick its box
if the section is clean on that criterion, otherwise leave the box and
write the line numbers you marked.** Draft mode numbers lines continuously
through the document, so the number alone locates the line. Each criterion
cell opens with the box and leaves the rest of its height free to write in.

This split is deliberate. A stroke is good at saying where and bad at
saying what — encoding four criteria as four underline styles means
choosing a notation mid-sentence while reading, and dashed against dotted
is unreadable a week later on a 10pt printout. Two unmistakable strokes
plus a line number on the form avoids both problems.

The strokes are declared in one editable block at the top of
`review-form.tex`:

```latex
\newcommand{\rvwmarkkey}{%
  \rvwmark{\uline{underlined text}}{something is wrong here, ...}%
  \rvwmark{\sout{struck through}}{cut this, or say it shorter}%
}
```

Each `\rvwmark` is `{sample}{meaning}`, drawn with `ulem` so it prints as
the actual stroke. Others exist if ever wanted: `\uuline`, `\uwave`,
`\dashuline`, `\dotuline`, `\xout`. The criteria themselves are named in
the key legend and the grid headings, and nowhere else.

### Using the form with any other document class

The form does not need `manuscript.cls`. Every class that uses a standard
`\section` leaves the section list in its `.aux` file, whether or not the
document prints a table of contents:

```
\@writefile{toc}{\contentsline {section}{\numberline {1}Introduction}{1}{}...}
```

Number, title and page, for free. `wordcount.py` can read that and write
the `.rvw` file the form expects:

```bash
pdflatex paper.tex                              # produces paper.aux
python3 wordcount.py paper.tex --sections-from-aux
pdflatex review-form.tex                        # with \rvwsource set to paper
```

One script writes both files, so the word counts cannot end up on the
wrong rows. `manuscript.cls` writes its own `.rvw` and needs no flag.

Three things are weaker in this mode, and the form shows which mode it is
in at the top right:

- **Starred sections are missing.** `\section*{Acknowledgment}` adds
  nothing to the contents, so nothing reaches the `.aux`. References being
  excluded is the same rule working in your favour.
- **No Body total row.** It was anchored to the first unnumbered section,
  which no longer exists here. The grand total is still shown.
- **No title or version.** A `.aux` holds neither, so those fields print
  as blank rules to fill in by hand.

The line numbers the form asks you to record are not automatic either.
Add them to your own preamble:

```latex
\usepackage[switch]{lineno}
\linenumbers
```

### Reviewing a paper you cannot build

Point `\rvwsource` at a name with no matching `.rvw` file and you get
blank numbered rows to fill in by hand. Adjust how many with
`\rvwblankrows`.

## Building

```bash
latexmk -pdf main.tex
```

Clean up with `latexmk -c`, or fully with `latexmk -C`.

## Title-block commands

Declared in the preamble, all emitted by `\maketitle`:

`\title`, `\author`, `\affiliation`, `\email`, `\keywords`, `\version`,
and `\thanksnote` for an unnumbered first-page footnote (funding and so on).

The `abstract` environment **must appear before `\maketitle`** — the class
captures it there and emits it full width inside the title block.

## Worked examples

Three sections in `main.tex` are worked examples rather than paper
content. Delete them, and their files, once you start writing.

| File | Covers |
|---|---|
| `sections/figures.tex` | Single-column figure, full-width `figure*`, side-by-side and stacked subfigures, text-wrapped `wrapfigure`, oversized image clamped with `adjustbox`. |
| `sections/tables.tex` | Simple `booktabs` table, grouped headers with `\multicolumn` and `\cmidrule`, merged rows with `\multirow`, wrapping text column with `tabularx`, decimal alignment with `siunitx`, table notes with `threeparttable`, full-width `table*`, oversized table clamped with `adjustbox`. |
| `sections/other.tex` | Cross-references, citations, numbered and aligned equations, list styles, footnotes, quotations. |
| `sections/appendix.tex` | Multi-page `longtable`, and the `\onecolumn` switch that makes it work in a two-column paper. |

Placeholder graphics live in `figures/`. The class sets `\graphicspath`
to that folder, so `\includegraphics{placeholder-a}` needs no path.
Replace the files with real figures and keep the folder.

Paper-specific macros such as `\ket` and `\bra` are defined in `main.tex`,
not in the class, so the class stays generic.

## Included by default

Typography: `newtxtext` + `newtxmath` (Times), `helvet` scaled to 0.92 as
the sans companion, `microtype`, `geometry`, `titlesec`, `fancyhdr`,
`xcolor`.

Floats: `graphicx`, `caption`, `subcaption`, `float`, `wrapfig`.

Tables: `booktabs`, `tabularx`, `multirow`, `makecell`, `longtable`,
`threeparttable`, `adjustbox`, `siunitx`. The class also defines `L`, `C`
and `R` as ragged variants of the `tabularx` `X` column.

Maths and references: `amsmath`, `amssymb`, `enumitem`, `natbib`
(numeric, sorted, square brackets), `hyperref`, `cleveref`.

Default bibliography style is `unsrtnat`. Change it in `main.tex`.

## One thing to know about `draft`

LaTeX already has a global `draft` option, and it means something quite
different: `graphicx` replaces every image with an empty box showing the
file name, `hyperref` disables links, `microtype` switches off. Because
every `\documentclass` option is offered to every package loaded
afterwards, our `draft` would have triggered all of that.

The class strips `draft` from the global option list, so it only ever
means what the table above says. This matters if you add packages of your
own to `main.tex` — they will not see a stray `draft` either.

## Fonts

Times, throughout text and maths.

Under pdflatex the actual Monotype Times New Roman is not available, so
the class uses **TeX Gyre Termes** via `newtx`, which is metrically
compatible with it and is the standard substitute. Maths comes from
`newtxmath`, which must be loaded after `amsmath` — the class handles the
ordering. Sans is Helvetica (`helvet`) at 0.92 scale, used only for the
draft line numbers; typewriter is newtx's own `t1xtt`.

Everything is embedded as a Type 1 subset, so the PDF carries its own
fonts and does not depend on what the printer has.

Run `pdffonts` on the output and you should see nothing but Times: TeX
Gyre Termes, `t1xtt`, Nimbus Sans and the newtx maths fonts. The
placeholder images in `figures/` are generated by
`figures/placeholders.tex` and are set in Times too.

One setting exists for this reason: `\sisetup` uses `per-mode=symbol`,
giving "kbit/s" rather than "kbit s⁻¹". Besides reading better, it avoids
a superscript that siunitx sets in a 7pt Computer Modern regardless of
the text font.

## Writing conventions

Two habits the template is built around, both worth adopting:

**One sentence per line** in the source. A changed sentence then shows as
one changed line in the diff, rather than a reflowed paragraph. The
per-section word counts and the review form both assume you can point at
a line and mean it.

**Comment out rather than delete.** Prefix a line with `%` to drop it
from the PDF while keeping it in the source. Ideas come back, and
recovering them from the git history is slower than scrolling.

## License

Two licenses, split by what each file is.

| Files | License |
|---|---|
| `manuscript.cls`, `review-form.tex` | LPPL 1.3c or later |
| `wordcount.py` | MIT |
| `main.tex`, `sections/`, `references.bib`, `latexmkrc`, `figures/` | CC0 1.0 |

The LaTeX sources use the LPPL because that is what the LaTeX world
expects of a class. Note its one real condition: if you distribute a
**changed** `manuscript.cls`, rename it, so a document asking for
`manuscript.cls` always gets the one it expects. Writing your own papers
with the class is not modification and carries no obligation.

The example content is CC0 so that nothing in a paper you write from this
template carries an obligation back to it.

Full texts in [LICENSE](LICENSE), [LICENSE-LPPL.txt](LICENSE-LPPL.txt)
and [LICENSE-MIT.txt](LICENSE-MIT.txt).
