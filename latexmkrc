# latexmk configuration for manuscript.cls
#
# Runs wordcount.py before each pdflatex pass so the per-section word
# counts in draft mode stay current. Counts lag by one pass on the first
# build; latexmk's rerun loop resolves that automatically.

$pdf_mode = 1;
$bibtex_use = 2;

# The review form is not a paper, so it gets no word count of its own.
$pdflatex = 'if [ "%B" != "review-form" ]; then '
          . 'python3 wordcount.py %S > /dev/null 2>&1; fi; '
          . 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';

push @generated_exts, 'synctex.gz';
$clean_ext = 'synctex.gz run.xml';

# .wcnt and .rvw are what review-form.tex reads. `latexmk -c` keeps the
# final PDF, so it must keep these too, or a form built after a clean
# comes out with empty word counts and no section list. Only the full
# `latexmk -C`, which removes the PDF as well, clears them.
$clean_full_ext = 'wcnt rvw';
