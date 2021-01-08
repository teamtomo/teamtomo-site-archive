# Contributing

We welcome contributions from anyone with anything useful to contribute!

The project is powered by [Jupyter Book](https://jupyterbook.org/intro.html). 
Contributing is fairly painless, requiring only a minimum of familiary with working at the command line.

## How to write your contribution
Contributions should be written in `Markdown`, a simple markup language for plain text files. 
A cheat sheet can be found [here](https://www.markdownguide.org/cheat-sheet/) and you can use the 
[repository](https://github.com/open-subtomo/open-subtomo) as a starting point.

## Adding your contribution to the project
The project lives on [GitHub](https://github.com/open-subtomo/open-subtomo). 
We make use of the version control system [git](https://git-scm.com/) and the 
[Pull Request](https://docs.github.com/en/free-pro-team@latest/github/collaborating-with-issues-and-pull-requests/about-pull-requests)
mechanism on GitHub to manage contributions.

## Step by step guide
### Step 1 - forking the project
A fork is your own online copy of an existing project on GitHub.
A guide to forking a project can be found [here](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo).

### Step 2 - downloading the project
Navigate to the folder in which you would like the project to be stored in your filesystem then run
the following command.

```bash
git clone https://github.com/<your-username>/open-subtomo.git
cd open-subtomo
```

Make sure to replace `<your-username>` with your GitHub username.

### Step 3 - create a new branch for your contribution

Create a new git 'branch' for your contribution and switch to that branch.

```bash
git checkout -b my-contribution
```

### Step 4 - add your file(s) and update the table of contents

Move your file(s) to where you think they should live within the project.
Once this is done, update the table of contents file `_toc.yml` to include the necessary links.

### Step 5 - build the site locally

Build the site locally to check that everything looks the way it should with the following command.

```bash
jupyter-book build .
```

Once the site is built, a link to open the local copy of the site in your web browser will appear.
Have a quick look at your contribution and if everything seems okay, move onto the next step.

### Step 6 - upload your contribution
Next you will upload your updated version of the project to your account on GitHub.

First, save your changes in the current branch.

```bash
git add .
git commit -m "added a new mini-tutorial on subboxing"
```

Then, upload your contribution with the `git push` command.

```bash
git push origin my-contribution
```

### Step 7 - propose integration of your contribution

Your contribution should now be present on your GitHub page. 
To propose merging your contribution into the main project, 
go to your version of the project on GitHub and click the `Compare & pull request button`.
Then, fill in some information about your contribution and click `Create pull request`.

