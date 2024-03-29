Using git and GitHub to manage your REMIND code
================
David Klein (<dklein@pik-potsdam.de>), Kristine Karstens (<karstens@pik-potsdam.de>)
15 February, 2020

# 1 Introduction

REMIND and related R packages are published as open-source software on GitHub. 
There are various workflows, how to use GitHub for collaborative
software development. We want to give some general remarks on our
prefered one. Note the following:

  - **Git** is a free and open source distributed version control system
    designed to handle everything from small to very large projects with
    speed and efficiency (from: <https://git-scm.com/> - very good help,
    documentation, tutorial page for git).

  - **GitHub** is an US American company (owned by Microsoft) that provides
    hosting for software development version control using Git. (GitLab,
    SourceForge and various more are open-source alternatives to
    GitHub.)
    

### Learning objectives

The goal of this exercise is to set up REMIND for collaborative working.
After completion of this exercise, you'll be able to:

1.  "Fork" and "clone" your personal REMIND repository
2.  Keep your personal repository up-to-date with the REMIND main repository
3.  Understand the basic workflow including pull requests and branches.
4.  Have heard some very basic git commands and know where to find more help.
    
# 2 GitHub workflow

## 2.1 Fork (on the GitHub server)

<img src="figures/git-1-setup.png" width="100%" style="display: block; margin: auto;" />

Every code development (even bugfixes) will be merged into our main (called "upstream")
repository under <https://github.com/remindmodel/remind> with the help
of so called pull requests. Pull requests give us control over the
changes entering our branches. To create a pull request, we use personal
or institutional forks. They have to be kept up-to-date with our
upstream repository (the original remindmodel fork).

> **Exercise**: Visit us on <https://github.com/remindmodel/remind> and
> create your own fork by clicking at 'fork' (at the upper right).

## 2.2 Clone (download your personal repository)

To run REMIND on your local machine or a high-performance cluster, you have to clone (download) the code from your fork.
This can be done with your preferred git client (e.g. the `git` command line program or [GitHub Desktop](https://desktop.github.com/)).
We recommend to upload an ssh-key and use ssh to connect to GitHub.

If you want to use the `git` command line program in windows, open a git bash as follows: 
open the file explorer, right-click on the folder you want to execute the git commands in and choose "Git Bash Here" from the context menu.
You need to have git installed.

Because of a storied history, the full REMIND repository is about 1.2 GB in size; therefore, it is recommended to only clone (download) the parts you need, or use a local reference repository if available.

### Option 1: With a local reference

If you have a local reference available (e.g. on the PIK cluster, or because you cloned REMIND previously), we strongly recommend to use it to avoid re-downloading and duplicating all data.
On the PIK cluster, use the `cloneremind` command like this:
```shell
cloneremind git@github.com:<yourname>/remind.git
```
where you replace `<yourname>` with your GitHub username.

If you are not on the PIK cluster but have a reference clone available, use
```shell
git clone --reference /path/to/reference/clone git@github.com:<yourname>/remind.git
```
where you replace `/path/to/reference/clone` with the path to your existing REMIND clone and `<yourname>` with your GitHub username.
Do not delete the reference.

### Option 2: Download only needed parts

If you don't have a local reference available, you can filter large files when cloning REMIND.
This saves a lot of time downloading everything and also saves space for storage, in exchange for needing to automatically download things on-demand if you want to examine old versions of remind.

Using the git command line program, use
```shell
git clone --filter=blob:limit=1m git@github.com:<yourname>/remind.git
```
where you replace `<yourname>` with your GitHub username.

### Option 3: Download everything

If you don't care for download time and storage requirements, or want access to all historical versions of REMIND without internet access, just clone normally.

Using the git command line program, use
```shell
git clone git@github.com:<yourname>/remind.git
```
where you replace `<yourname>` with your GitHub username.

### Exercise

> **Exercise**: Visit your fork and clone the repository at your
> machine.

## 2.3 Push (to your personal repository)

<img src="figures/git-2-pushing.PNG" width="100%" style="display: block; margin: auto;" />

When you start making your first changes to the code at your local copy,
we strongly recommend to read a tutorial to get familiar with the basic
commands in Git. We have compiled a typical workflow at the end of this tutorial (section 3) (you can also have a look on 'git cheat sheets' like
<https://about.gitlab.com/images/press/git-cheat-sheet.pdf>).

After you have added your changes locally, push (upload) them to your personal remote repository.

## 2.4 Pull (updates from the upstream repository)

To keep your fork up-to-date with the upstream repository you can use
the GitHub interface. Via `Compare` you can check if the
upstream is some commits ahead. If so merge these new changes into
your fork. 

<img src="figures/git-3-add-upstream.PNG" width="100%" style="display: block; margin: auto;" />
<img src="figures/git-4-pull-upstream.PNG" width="100%" style="display: block; margin: auto;" />

You can also do this merging procedure in your local copy by adding 
both your fork and the upstream repository as so called 'remotes' to 
your local repository.

> **Exercise**: Check, if there is anything to merge from the upstream
> repository into your fork. If so, merge it into the local clone of your 
> personal fork.

## 2.5 Pull request

After you have committed your changes locally, merged the latest updates from the remote upstream repository and 
pushed the result to your remote personal repository it is time to get it integrated
into the remote upstream repository. Instead of pushing them directly into the remote upstream repository we use so called
pull requests. Pull requests are proposed changes to a repository submitted by you and accepted or rejected by a 
repository collaborator. Like issues, pull requests each have their own discussion forum.

**Note:** it is rather useful to do your work on feature branches rather than on the default `develop` branch. This
helps you keep better track of your work and also helps your colleagues understand easier what your recent pull request
was about. So naming your branch "bugfix_make_feature_XX_operational_again" will greatly help. See below for more on 
working with branches.
 
<img src="figures/git-5-pull-request.PNG" width="100%" style="display: block; margin: auto;" />
<img src="figures/git-7-pull-request-github-1.PNG" width="100%" style="display: block; margin: auto;" />
<img src="figures/git-8-pull-request-github-2.PNG" width="100%" style="display: block; margin: auto;" />

## 2.6 All steps in one figure

<img src="figures/git-6-all-in-one.PNG" width="100%" style="display: block; margin: auto;" />
<img src="figures/git-11-rules.PNG" width="100%" style="display: block; margin: auto;" />

# 3 Incorporate your code changes by using branches

<img src="figures/git-9-branching.PNG" width="100%" style="display: block; margin: auto;" />
<img src="figures/git-10-branching-advanced.PNG" width="100%" style="display: block; margin: auto;" />
