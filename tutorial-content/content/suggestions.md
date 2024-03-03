# Suggestions for work organization 

```{admonition} Key objectives
:class: note
- Understand how to organize your project data and code.
- Learn about useful tools that will help you work productively.
```

Following these suggestions will help you organize your research, which could improve [reproducibility](https://the-turing-way.netlify.com) (replicability) and reusability of your code and results. In computational research, reproducibility is the ability to obtain consistent results using the same input data, code, and methods. Considering these early on is particularly helpful when collaborating with other researchers (including a future self). 

(content:code-organization)=
## Organization of data and code

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

Good naming practices should be applied to files and folders to make clear the contents of your project. Informative naming will help you understand the purpose of each file, and it will improve its findability. Here are a few recommendations:

`````{grid}
:gutter: 2

````{grid-item-card} Do's

✅ Use delimiters (such as underscores "_" or dashes "-") to separate information contained in the file name.

✅ Make sure file names are informative of their contents, and be consistent in using a naming scheme. 

✅ If you want to indicate sequence, start your file or folder names with numbers (e.g., `01_clean_data`, `02_analyze`, `03_results`)

✅ Use ASCII encoding if possible, with UTF-8 or UTF-16 as secondary options.
````
````{grid-item-card} Don'ts

❎ Don't use spaces, punctuation, accented characters or case sensitivity. Use periods for file type only (e.g., `.csv`)

❎ Don't use extra-long file and folder names, they should be as concise as possible while still being descriptive. 

❎ Don't use proprietary file formats for storing image data. Images, pictures, or figures should be saved as JPEG or GIF files.
````
`````


```{admonition} Data storage 
:class: tip
Most universities have a data storage product available for their students and affiliates. 
We recommend you inquire at your university about what can be the best place to store data.
```

## Documentation

Even if you have organized your working directory perfectly, it is still good to include additional documentation in readme files (`readme.txt` or `README.md`). A README file is usually a plain text file stored in a top-level directory. Describe the files and process in these files, and try to keep them up-to-date as things are added or changed. Project documentation will be primarily helpful to you later on (for example, if you need to reuse the code with some modifications), but also to your peers and collaborators in case you share your data and code. Here are a few tips on creating a good README file:


````{grid}
:gutter: 2

```{grid-item-card} Do's

✅ Include a project description, explain how data was obtained and analyzed.

✅ Include a breakdown of naming conventions that will apply to files and variables in the dataset.

✅ Include names and contact information (when appropriate) of dataset creators and maintainers.
```
```{grid-item-card} Don'ts

❎ Don't forget to document your code, add information on software versions, and how to run your code.

❎ Don't use abbreviations, acronyms, or code names without defining them.

❎ Don't include personal information about authors or maintainers without their consent.
```
````

```{note}
All documentation should be stored in non-proprietary file formats, such as `.txt`, `.md`, `.xml` or `.pdf`.
```

```{note}
When data files cannot be converted into open formats (particularly geospatial polygon data), make sure to document the software package, version, and native platform.
```

## Version control

We recommend using version control to track changes to your code files. There are many advantages to using version control software, and here we list a few:

1. It enables multiple collaborators to simultaneously work on a single project. With version control, each collaborator can freely make changes to any project files, as it allows merging all the changes into a common version.
2. It saves every version of your project after making changes, which is a great habit (see Figure below). This means that you can restore previous versions of the files, in case they can be useful or prove to be better than the latest ones. 
3. Using version control for developing your code can help understand what has changed between each version and troubleshoot potential new bugs. It may also help you identify and solve them.
4. Finally, version control can act as a backup of your project. In case your computer breaks, you can always retrieve the latest version of the project from your colleagues or a remote repository. This feature also allows you to work on multiple computers seamlessly. 

```{figure} https://www.groovecommerce.com/hs-fs/hub/188845/file-4063238065-png/blog-files/version-control-comic.png
```

```{seealso}
We highly recommend you to go through [a tutorial on version control with git](https://swcarpentry.github.io/git-novice/).
```

## Workflow automation

Automation combines all analysis steps in a cohesive analysis ensemble or a workflow. 
The goal of automation is to enable a streamlined analysis execution, ideally only with a single command. 

The file that defines analysis workflow is often called a 'master script'. A master script can be written in different languages, like MATLAB, R, Python, bash etc. A master script written in [bash](http://swcarpentry.github.io/shell-novice/) is typically called `run_all.sh`, `runall.sh` or similar.

An example of a master script in bash showcasing a simple workflow sequence:

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

```{admonition} Immutable data
:class: warning
Original data (or source or raw data) should be immutable, meaning that it should never be modified by your code. 
Instead of making changes to the original data, you should create derived (new) datasets.
This is important because the pre-processing performed on source data is as important as the final analysis steps.
In addition, it will allow you to reuse the original data multiple times.
```

```{admonition} Relative and absolute paths
:class: caution
A common problem when automating and packaging your project is the use of absolute paths.
An absolute or full path points to a location on the filesystem from the root, often containing system-specific sub-directories (for example: `/home/username/project/data/input.csv`). 
A relative path, on the other hand, only assumes a local relationship between folders (for example: `../data/input.csv`, where ".." refers to the "parent" directory). You should specify relative paths whenever that is possible.
```

## Research dissemination


Research data repositories are a primary venue for data dissemination. Use [the Registry of Research Data Repositories (re3data.org)](https://www.re3data.org) to find the right repository for your research data. Alternatively, general-purpose repositories such as [Dataverse](https://dataverse.harvard.edu/), [Figshare](https://figshare.com/), or [Zenodo](https://zenodo.org/) are a good and freely-available option. However, before sharing or opening your data, make sure that there are no privacy, security, or license constraints. 

If you'd like your research data and code to be reusable already in a web browser, consider using [one of the reproducibility platforms](https://researchintegrityjournal.biomedcentral.com/articles/10.1186/s41073-020-00095-y). For instance, the platform [Code Ocean](https://codeocean.com) facilitates data and code sharing in languages such as MATLAB, Stata, R, Python, C++, etc. This also means that code based on proprietary software (MATLAB or Stata) can be executed and reused online free of charge. See a [demonstration of shared research data and code in Code Ocean](https://codeocean.com/capsule/8792614) originally published in [(Deschênes & Greenstone)](https://www.aeaweb.org/articles?id=10.1257/app.3.4.152).

```{note}
When sharing your research data, don't forget to include licensing information. A standard license should be used. Don't ask users to "email authors about reuse," but instead pick a restrictive license.
```

```{seealso}
For more information on data sharing, see [Mozilla Science Lab's Open Data Primers](https://mozillascience.github.io/open-data-primers/).
```
