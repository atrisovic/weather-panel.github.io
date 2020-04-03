---
title: 'ClimateEstimate.net: A tutorial on climate econometrics'
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

The use of econometrics to study how social, economic, and biophysical systems respond to weather has started a torrent of new research [@carleton2016social]. It is allowing researchers to better understand the impacts of climate change, disaster risk and responses, resource management, human behavior, and sustainable development. However, several steps in the research process can be challenging to social science researchers because of the unfamiliarity of weather data, and mistakes remain common [@nissan2019use]. While existing academic work has provided overviews of climate science for econometricians [@hsiang2018economist] and the theoretical backing of these methods [@hsiang2016climate], new resources are needed to offer practical help to researchers.

This tutorial aims to fill the gap, offering step-by-step guidance. However, unlike traditional single-example tutorials, our approach is to inform each of the myriad decision-points necessary to perform weather regression research for a new problem. These decision-points include:
1. The selection of relevant weather variables, and of the data sources for those variables in light of their strengths and weaknesses.
2. How gridded weather data should be related to regionally-defined socioeconomic data.
3. The different modelling decisions necessary to relate socioeconomic outcomes to weather variables through a regression specification.
4. Finally, how to effectively organize data and code, and what tools to use to improve productivity and research reproducibility.

While the challenges of weather econometrics are similar across all problems, the appropriate choices are unique to each research question. No single sequence of steps will be widely applicable. Similarly, software aimed at facilitating steps in this process needs to be fully understood and operated with care. In light of this, the tutorial offers code snippets in multiple languages and points to several pre-existing packages while providing some introductory comments on their appropriate use.

The audience for this tutorial is researchers and students trained in econometrics and experienced in at least one scientific programming language, such as Stata, R, Matlab, Julia, or python. In this rapidly evolving and interdisciplinary field, the tutorial is free and open-source and invites authors to contribute more information. It is implemented in a [JupyterBook](https://jupyterbook.org/intro) and available online at [climateestimate.net](https://climateestimate.net/getting-started.html).

The proper interpretation, use, and projection of this form of econometric result introduces additional decision-points [@ciscar2019assessing], which will be discussed in future work on the tutorial. Other planned extensions of the tutorial will offer guidance on how to develop academically interesting and policy-relevant research questions, produce engaging visual displays, and ensure that research results can be updated as new data becomes available.

# Acknowledgements

We would like to acknowledge contributions from Manuel Linsenmeier. A. Trisovic is funded by the Sloan Foundation.

# References
