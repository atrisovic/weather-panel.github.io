# Contributing 

To contribute to the repository, you'll need to make your own fork. Then, clone the repository locally and make a new branch for your contribution.

```
git checkout -b my-awesome-contribution
```

## Setting up the working environment

You will need Python 3, i.e., Python 3.7.

Install the necessary dependencies with:

```
pip install -r requirements.txt
```

## Making changes to the content

To update the webpage, make changes to the `.md` files in the `content` folder.
You could also add images or jupyter notebooks. For inspiration, see [The Turing Way guide](https://the-turing-way.netlify.com).

## Testing the website

Create a local jupyter-book to see and test the new content:

```
jupyter-book build .
make serve
```

View it at `localhost:4000`.

## Create a pull request 

1. Make sure that the jupyter-book build works on your computer and that all content looks as it should (i.e., text styles, formulas, images).
2. Commit only changes from the `content` folder and make a pull request. 
3. Once the changes are reviewed and merged, the webpage will be automatically rebuilt and updated at [climateestimate.net](https://climateestimate.net/getting-started).

Thank you for contributing!

