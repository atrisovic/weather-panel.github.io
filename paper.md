---
title: 'A practical guide to climate econometrics: Navigating key decision points in weather and climate data analysis'
tags:
  - climate change
  - econometrics
  - tutorial
authors:
  - name: James A. Rising
    orcid: 0000-0001-8514-4748
    affiliation: 1
  - name: Azhar Hussain
    orcid: 0000-0002-6475-1052
    affiliation: 2
  - name: Kevin Schwarzwald
    orcid: 0000-0001-8309-7124
    affiliation: 3
  - name: Ana Trisovic
    orcid: 0000-0003-1991-0533
    affiliation: 4
affiliations:
 - name: Grantham Research Institute, London School of Economics
   index: 1
 - name: Department of Economics, London School of Economics
   index: 2
 - name: Department of Earth and Environmental Sciences, Columbia University
   index: 3
 - name: The Institute for Quantitative Social Science, Harvard University
   index: 4
date: 1 March 2020
bibliography: paper.bib
---

# Summary

The use of econometrics to study how social, economic, and biophysical systems respond to weather has started a torrent of new research [@carleton2016social]. It is allowing researchers to better understand the impacts of climate change, disaster risk and responses, resource management, human behavior, and sustainable development.

The research often features weather regression modeling and analyzing socioeconomic outcomes as they vary over time. The researchers need to collect, integrate, and analyze many different datasets such as historical climate data, future climate models, GIS information, and administrative data, in order to obtain meaningful and comprehensive results. While the challenges of climate econometrics are similar across all problems, the appropriate use of data, its integration and aggregation are unique to each research question, thereby presenting a stumbling block to early-career researchers. No single sequence of steps can be widely applied for resolving these issues. Similarly, software aimed at facilitating steps in this process needs to be fully understood and operated with care. 

In light of this, we present a new tutorial that offers step-by-step guidance on carrying out a climate econometric analysis. Moreover, it features reusable code snippets in multiple programming languages and points to several pre-existing packages while providing some introductory comments on their appropriate use. The tutorial is structured into the following sections:

1. Introduction: explains the prerequisites, introduces definitions and conventions, and recommends relevant literature.
2. Using weather and climate data: introduces the data and its attributes, the NetCDF file format, supported programming languages, and common limitations of the data.
3. Developing a reduced-form specification: provides a number of considerations before starting an analysis, such as choosing weather variables, functions for creating a model, and caveats when working with spatial and temporal processes.
4. Weighting schemes: explains the importance of weighting schemes and how to work with them based on their file formats and origins. 
5. Generating geographical unit data: introduces geographic information systems, shapefiles, and how to work with them effectively.
6. Suggestions for work organization: presents recommendations for organizing research, including naming conventions, version control, and automation, which can improve researchers' productivity and research reproducibility.
7. Contributions: introduces the current tutorial contributors and invites authors to contribute more information.

The audiences for this tutorial are researchers and students trained in econometrics and experienced in at least one scientific programming language, such as Stata, R, Matlab, Julia, or Python. In addition to its use in a teaching event or for self-study, this tutorial can also be used as a reference manual, as each of its topics and lessons can be comprehended independently.

Over the past year, the tutorial has been actively used by Ph.D. and Master's students at the London School of Economics, and it has been highlighted at multiple workshops. Several independent research projects have been developed by following the steps of the tutorial, which provides additional evidence for the success of its learning objectives.

In this rapidly evolving and interdisciplinary field, our tutorial is free and open-source. It is implemented as a [JupyterBook](https://jupyterbook.org/) and available online through [Github Pages](https://pages.github.com) at [climateestimate.net](https://climateestimate.net/getting-started.html). Its implementation also features a deployment workflow through [GitHub Actions](https://github.com/features/actions), meaning that every time there is an update to the `master` branch, the action will automatically build a new JupyterBook and update the tutorial website within minutes. As a result, contributors can change the tutorial content in markdown files without worrying about updating it on the web.

# Statement of Need

The literature currently provides overviews of climate science for econometricians [@hsiang2018economist] and the theoretical backing of these methods [@hsiang2016climate]. However, information that focuses on analysis methods is still lacking, and new resources are needed to offer practical help to researchers. For example, several steps in the research process can be challenging to students and social science researchers because of unfamiliarity with weather data [@nissan2019use]. As a result, some of the most common mistakes are: 

1. Choosing inappropriate weather variables (e.g., variables with poor observational records, or statistics of variables that do not reflect the analyzed socioeconomic relationship) or underestimating the uncertainty of weather data products, especially those relating to hydrological variables such as rainfall.
2. Mismatching gridded weather data to non-gridded socioeconomic data and failing to choose a weighting scheme that reflects the underlying biophysical processes. 
3. Selecting regression specifications that miss or misrepresent key features of the socioeconomic relationship, such as nonlinearity and local scale interactions.

Our climate econometrics tutorial aims to fill the identified knowledge gaps by providing detailed and accessible guidelines on each step in the research process, from data collection and analysis design, to the plotting of results. Unlike traditional single-example tutorials, our approach is to inform each of the myriad decision-points necessary to perform weather regression-based research for a new problem. These decision-points include:

1. The selection of relevant weather variables and data sources, given their unique strengths and weaknesses.
2. How gridded weather data should be related to regionally-defined socioeconomic data.
3. The different modeling decisions necessary to relate socioeconomic outcomes to weather variables through a regression specification.

The proper interpretation, use, and projection of this form of econometric result introduces additional decision-points [@ciscar2019assessing], which will be discussed in future work on the tutorial. Other planned extensions of the tutorial will offer guidance on developing academically interesting and policy-relevant research questions, producing engaging visual displays, and ensuring that research results can be updated as new data becomes available.

# Acknowledgements

The authors would like to acknowledge contributions from Manuel Linsenmeier. A. Trisovic is funded by the Alfred P. Sloan Foundation (grant number P-2020-13988).

# References
