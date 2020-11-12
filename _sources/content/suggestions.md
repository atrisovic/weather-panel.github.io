# 5. Suggestions when producing a panel dataset

Following these suggestions will help you organize your research, which could improve [reproducibility](https://the-turing-way.netlify.com) (replicability) and reusability of your code and results. These could be particularly helpful when collaborating with other researchers (including a future self). 

## 5.1 Organization of data and code

Having a single directory for a project, containing all data and code in subdirectories 
makes it easier to find things, and also, in case you want to zip everything up and send it to someone else.
However, try to keep your code and your data separate. A typical file organization should be:

  - `code/` - all of your analysis
  - `sources/` - the original data files, along with information so you can find them again
  - `data/` - merged datasets that are ready to be analyzed
  - `results/` - result files, typically not formatted for display.
  - `figures/` - formatted figures and LaTeX tables.

If you are not sure what predictors you will need for your analysis,
create your dataset with a lot of possible predictors and decide
later.  Often merging together your panel dataset is laborious, and
you do not want to do it more times than necessary.

Even if you have organized your working directory perfectly, it is still good to include 
some additional documentation in readme files (readme.txt, readme.md).
Describe the files and process in these files, and try to keep them up-to-date as things are added or changed. 

```{admonition} Data storage 
:class: tip
Most universities typically have a data storage product available for their students and affiliates. 
We recommend you inquire at your university about what can be the best place to store data.
```

```{admonition} Immutable data
:class: warning
Original data (or source or raw data) should be immutable, meaning that it should never be modified by your code. 
Instead of making changes to the original data, you should create derived (new) datasets.
This is important because the pre-processing performed on source data is as important as the final analysis steps.
In addition, it will allow you to reuse the original data multiple times.
```

## 5.2 Naming conventions

Good naming practices should be applied to files and folders to make clear the contents of your project. 
Informative naming makes it easier to understand the purpose of each item and can improve searchability.

Recommendations:

1. Avoid spaces, punctuation, accented characters, case sensitivity. Use periods for file type only (e.g., `.csv`)
2. Use delimiters (such as underscores "_" or dashes "-") to separate information contained in the file name.
3. Ensure file names are informative of its contents
4. If you want to indicate sequence, start your file or folder names with numbers (e.g., `01_clean_data`, `02_analyze`, `03_results`)


## 5.3 Version control

We recommend using version control to track changes to your code files. There are many advantages to using a version control software, like, it enables multiple collaborators to simultaneously work on a single project, or a single person to use multiple computers to work on a project. 
Also, it gives access to historical versions of your project. 

```{seealso}
We recommend you to go through [a tutorial on version control with git](https://swcarpentry.github.io/git-novice/).
```

Here is one more reason to use version control:

![](https://www.groovecommerce.com/hs-fs/hub/188845/file-4063238065-png/blog-files/version-control-comic.png)

## 5.4 Workflow automation

Automation combines all analysis steps in a cohesive analysis ensemble or a workflow. 
The goal of automation is to enable a streamlined analysis execution, ideally only with a single command. 

Here is an example that showcases a simple workflow sequence with [bash](http://swcarpentry.github.io/shell-novice/).
The file that defines analysis steps is often called a 'master script'.
A master script can be written in different languages, like MATLAB, R, Python, bash etc.

A master script written in bash that defines an analysis workflow is typically called run_all.sh, runall.sh or similar.

### An example of a master script in bash:

```bash
#!/bin/bash
# file: run_all.sh
python clean_data.py

# the command echo can help with tracking progress
echo "Finished with data cleaning"

python analysis.py
echo "Finished with analysis"

# Use comments like this one
# to add additional explanations
python draw_plots.py
echo "Finished with drawing plots"
```

The analysis is then executed with a single command in the command prompt (Terminal):

```bash
sh run_all.sh
```

```{admonition} Relative and absolute paths
A common problem when automating and packaging your project is the use of absolute paths.
An absolute or full path points to a location on the filesystem from the root, often containing system-specific sub-directories (for example: `/home/username/project/data/input.csv`). 
A relative path, on the other hand, only assumes a local relationship between folders (for example: `../data/input.csv`, where ".." refers to the "parent" directory). You should specify relative paths whenever that is possible.
```
