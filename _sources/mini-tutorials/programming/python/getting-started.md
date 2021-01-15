# Getting started

This mini-tutorial will help you set up a working `Python` environment on a Linux system. 
This will allow you to work with other peoples `Python` tools and start writing your own scripts.

## Some concepts
First, let's go over a few important concepts.

### What is `Python`?
`Python` is a widely used general-purpose programming language, known for its emphasis on code readability.

### How do I get `Python`?
`Python` comes preinstalled on Mac OS, most Linux distributions and is easily installed on Windows.

```{warning}
The system often depends on the preinstalled `Python` installation for various operations.
Modifying the system installation is not recommended.
```

Instead of using the preinstalled version of `Python`, it is recommended to work using what are called 
[virtual environments](virtual-environments). 

Setting up and managing virtual environments, including package management, is the focus of this mini-tutorial.

### What is a `Python` package?
When you write code, you may want to use some parts other people have written, 
rather than rewriting everything from scratch. 
If you reference and external code in your code, we say that your code *depends* on that external code.

In `Python`, people often package up their code and make it available on the 
[Python Package Index](https://pypi.org/) for others to download and use in their programs.

## Setting up your environment

### Installing `miniconda3`
In this tutorial, we will use a lightweight installation of 
[conda](https://docs.conda.io/en/latest/) 
called 
[Miniconda3](https://docs.conda.io/en/latest/miniconda.html) to manage our software environments.

```{note}
`conda` is not `Python` specific, it can be used as a general software environment solution. 
This is useful if you use software which has many specific dependencies and requires activation prior to usage.
```

Follow the installation instructions 
[here](https://conda.io/projects/conda/en/latest/user-guide/install/linux.html).

### Creating a new conda environment

The following command will create a new `conda` environment called `py38` with `Python` version 3.8.

```bash
conda create --name py38 python=3.8
```

This environment can be activated with `conda activate py38` and deactivated with `conda deactivate`.

### Installing packages

Once your environment is active, any packages you install will be installed into this environment, isolated 
from your system `Python` installation and other `conda` environments. 

Packages can be installed with either `conda install <package-name>` or `pip install <package-name>`.
