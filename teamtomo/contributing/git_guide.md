# A short guide to git(hub)

## Step 1 - forking the project
The first step is 'forking' the project. A 'fork' is your own online copy of an existing project on GitHub.

A guide to forking a project can be found [here](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo). If you're in a hurry, simply log into your GitHub account, head to [the repo](https://github.com/teamtomo/teamtomo.github.io) and click the `Fork` in the top left.

### Step 1.5 - installing git lfs
To keep the size of the repository small we use [git large files storage](https://git-lfs.github.com/). If you plan to add images to your contribution, you should install it. Check out [this page](https://github.com/git-lfs/git-lfs/wiki/Installation) to find the commands needed for your specific operative system. 

Otherwise, simply install it [from the link](https://git-lfs.github.com/), add it to your `$PATH` and run the install command:
```bash
git lfs install
```

## Step 2 - downloading the project
Navigate to the folder in which you would like the project to be stored in your filesystem then run the following command to clone the files locally:

```bash
git clone https://github.com/<your-username>/open-subtomo.git
cd open-subtomo
```

Make sure to replace `<your-username>` with your GitHub username.

## Step 3 - create a new branch for your contribution
Create a new git 'branch' for your contribution and switch to that branch.

```bash
git checkout -b <my-contribution>
```

## Step 4 - add your file(s) and update the table of contents
Add your file(s) to where you think they should live within the project (take a look at the structure of the existing files for inspiration).
Once this is done, update the table of contents file `_toc.yml` to include the necessary links.

## Step 5 - build the site locally
Build the site locally to check that everything looks the way it should with the following command.

```bash
jupyter-book build .
```

Once the site is built, a link to open the local copy of the site in your web browser will appear.
Have a quick look at your contribution and if everything seems okay, move onto the next step.

## Step 6 - upload your contribution
Next you will upload your updated version of the project to your account on GitHub.
First, save your changes in the current branch.

```bash
git add .
git commit -m "added a new mini-tutorial on subboxing"
```

Then, upload your contribution with the `git push` command.

```bash
git push origin <my-contribution>
```

Replace <my-contribution> with whatever you prefer to call this branch.

## Step 7 - propose integration of your contribution

Your contribution should now be present on your GitHub page. 
To propose merging your contribution into the main project, 
go to your version of the project on GitHub and click the `Compare & pull request button`.
Make sure that you are "Comparing across forks" and that the repository on the left is `teamtomo/teamtomo.github.io:master`, while the one on the right is `<your-username>/teamtomo.github.io:<my-contribution>`.
Then, fill in some information about your contribution and click `Create pull request`.
