# 5. Suggestions when producing a panel dataset

Keep your code and your data separate. A typical file organization will be:

  - `code/` - all of your analysis
  - `sources/` - the original data files, along with information so you can find them again
  - `data/` - merged datasets that are ready to be analyzed
  - `results/` - result files, typically not formatted for display.
  - `figures/` - formatted figures and LaTeX tables.

If you aren’t sure what predictors you will need for your analysis,
create your dataset with a lot of possible predictors and decide
later.  Often merging together your panel dataset is laborious, and
you do not want to do it more times than necessary.

