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

Each section gets two rows. The first has four criterion columns — **C/E**
claim clear and evidence sufficient, **S/F** structure and flow, **Eng**
English and phrasing, **Cut** cut or expand — and the second is a
full-width **Notes** band with no internal rules, for writing across.
Below the grid sit an overall block and a verdict line.

The form runs to as many pages as it needs. Two knobs control the writing
space: `\rvwrowheight` for the line-number row, `\rvwnoteheight` for the
notes band beneath it.

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

### Reviewing someone else's paper

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

Two things that are meant to be there, if you run `pdffonts`:

- **Latin Modern** entries come from the placeholder images in
  `figures/`, which have their labels drawn in it. They disappear once
  you replace them with real figures.
- `\sisetup` uses `per-mode=symbol`, giving "kbit/s" rather than
  "kbit s⁻¹". Besides reading better, it avoids a superscript that
  siunitx sets in a 7pt Computer Modern regardless of the text font.

## Writing conventions

See `latex_rule.md` at the vault root. One sentence per line, comment out
rather than delete, propose before editing.
