# Contributing 

## Setting up

In order to make changes to this website, you will need to use Python 3 (i.e., Python 3.7)

Install the necessary `jupyter-book` package with:

```
pip install jupyter-book
```


Run the following commands to clone the repo:

```
git clone https://github.com/atrisovic/weather-panel.github.io.git
cd weather-panel.github.io.git
```

## Making changes to the content

To update the webpage, make changes to the `.md` files in the `content` folder.
You could also add images or jupyter notebooks. (For inspiration see for example: https://the-turing-way.netlify.com)

## Testing the look of the website

To see the new look of the webpage run:

```
jupyter-book build .
make serve
```

and see the web page locally at: localhost:4000

## Commit to the repository

Once you want to commit your changes, add with `git add` all files that were created with `jupyter-book build .` (for example with: `git add -u`).
Once the changes are committed, the webpage will be automatically updated at: https://atrisovic.github.io/weather-panel.github.io/
