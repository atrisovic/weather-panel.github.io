# Practical guide to climate econometrics

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3739517.svg)](https://doi.org/10.5281/zenodo.3739517)
[![status](https://jose.theoj.org/papers/b8083032c189d1d472dc228b55ccd086/status.svg)](https://jose.theoj.org/papers/b8083032c189d1d472dc228b55ccd086)

This is a repository for a practical guide to climate econometrics available at [climateestimate.net](https://climateestimate.net/content/getting-started.html).

The primary audience for this guide is researchers and students trained in econometrics and experienced in at least one scientific programming language, such as Stata, R, Matlab, Julia, or Python. It could be used both in a teaching event, self-study or as a reference manual.

## Contributing to the guide

We welcome any contributions to the guide. One way to contribute is by opening an issue in this repository. Also, you could create direct changes to the guide and make a pull request. In this case, you'll need to make your own fork of the repository, clone the fork locally, and make a new branch for your contribution. For example:

```
git checkout -b my-awesome-contribution
```

### Making changes to the content

To contribute to the guide, make changes to the `.md` files in the `tutorial-content/content` folder.
You could also add images or jupyter notebooks. For inspiration, see [Jupyter Book](https://jupyterbook.org/contribute/intro.html) and [the Turing Way guide](https://the-turing-way.netlify.com).

### Testing the website

To test your contribution in the jupyter-book, you will need Python 3, i.e., Python 3.7. The following commands install the necessary dependencies in a virtual environment (`env`) and build a local version of the jupyter-book:

```
python3 -m venv env
. env/bin/activate
pip install -r requirements.txt

jupyter-book build tutorial-content/
```

Check out the updated notebook by opening this file in a browser:
`tutorial-content/_build/html/index.html`

### Create a pull request 

1. Make sure that the `jupyter-book` build works on your computer and that all content looks as it should (i.e., text styles, formulas, images).
2. Commit only changes from the `content` folder and make a pull request. 
3. Once the changes are reviewed and merged, the webpage will be automatically rebuilt and updated at [climateestimate.net](https://climateestimate.net/content/getting-started.html).

Thank you for your contribution!

