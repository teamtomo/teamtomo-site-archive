# Simple subtomogram averaging

This mini-tutorial will show you how to quickly set up and run a subtomogram averaging experiment in `Dynamo`.
In `Dynamo` lingo, this is referred to as an 'alignment project'.

We will set up our alignment project from the 'Dynamo current project' GUI (`dcp`).

Alignment projects can also be set up from the 
[`MATLAB` shell](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Advanced_starters_guide#Project_to_find_membrane_orientations) 
or the 
[Linux command line](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Scripted_creation_of_a_project_in_the_Linux_command_line).
You can also set up your project locally, then 
[bundle it up and send it to a remote machine/cluster](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Tarring_projects).

## Prerequisites
- a set of particles in a `Dynamo` [data container](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Generic_data_containers)
- (optional) metadata for each particle in a `Dynamo` [table file](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Table)
- (optional) a reference volume with the same dimensions as your particles
- (optional) a mask around your region of interest

## Setup

First, we need to open `Dynamo`, either activating it in `MATLAB` or using the standalone version.

### Open the `dcp` gui
`````{margin}
````{tip}
If you are using the standalone version of `Dynamo`, you can run `dcp` from the Linux command line directly with
```
dynamo >> dcp
```
````
`````
The `dcp` GUI is the main tool in `Dynamo` for interactively designing subtomogram averaging experiments.

To open the GUI simply run `dcp` from your `Dynamo` shell.


### Name the project
Click in the box to the right of `Project name` and write a name for your project. 
Choose something descriptive, it might help you remember what you did in a few months time!

Hit `Enter`. In the dialogue box which pops up, confirm that you would like to create a new project by clicking `Create new project`.

![name your project image](simple-alignment.assets/name-project.gif)

### Input files
#### Input your particles
Click on the `particles` button in the `Input: files` row. In the dialogue box which pops up, enter the name of your data file.

````{margin}
```{tip}
To keep your workspace tidy, close the dialogue boxes once you are finished with them. They tend to build up quickly!
```
````

``````{panels}
:column: col-20
:card: border-2
```{tabbed} particles
Click on the `particles` button in the `Input: files` row. 
In the dialogue box which pops up, enter the name of your data file.

![select particles image](simple-alignment.assets/select-particles.gif)
```

```{tabbed} table
Click on the `table` button in the `Input: files` row. In the dialogue box which pops up, enter the name of your table file.
If you don't have a template, you can generate a blank table or a random table using the buttons in the Dialogue box.
![select table image](simple-alignment.assets/select-table.gif)
```

```{tabbed} template
Click on the `template` button in the `Input: files` row. In the dialogue box which pops up, enter the name of your template file.

If you don't have a template, a random subset of the data can be used to generate an initial reference volume from the GUI by selecting
one of the options in the `I want to create a template` section, setting the desired number of particles and hitting `Average data`.

![create template image](simple-alignment.assets/create-template.gif)
```

`````{tabbed} masks
Click on the `masks` button in the `Input: files` row. In the dialogue box which pops up, you can enter up to four files

- an alignment mask
- a classification mask
- a Fourier mask for the template
- a Fourier shell correlation mask

![default masks image](simple-alignment.assets/masks-default.gif)

The `Use default masks` button will create masks covering the full extend of real space and fourier space for each mask automatically.

````{margin}
```{tip}
You can check that your mask properly covers your template using the `View mask -> overlay x/y/z` menu options.
```
````
The alignment mask defines a masked region of real space in which cross correlations used for alignments will be calculated.
The classification mask defines a masked region of real space in which cross correlations used for classification will be calculated.
The Fourier mask for the template defines the region of Fourier space in which you have information in your template (reference) volume.
The Fourier shell correlation mask defines a masked region of real space in which Fourier shell calculations will be calculated.

Each mask can be created from the GUI directly, or an external mask can be provided. The classification mask and the Fourier shell correlation mask are not
relevant for simple, single reference alignment projects such as the one we are setting up.
`````
``````

### Alignment parameters

From the `dcp` GUI click `numerical parameters` in the `Input: settings` row. This will open up a separate window in which many parameters relating to the numerical aspects of your alignments can be defined.

```{image} simple-alignment.assets/numerical-params.png
:width: 600px
```

```{attention}
You should think carefully about how much you allow particles to move during an iterative alignment experiment. Particles have a tendency to 'wander off' in low SNR environments, restricting the evolution of shifts appropriately (`shift limiting way` 3 or 4) can reduce this problem. 

If your angular parameters come from a geometrical model, restricting angular searches ensures the particles do not deviate too much from initial estimates.
```

Key info:
- Hit `alt` on your keyboard or the `?` button for more info on a parameter
- Alignment projects can be split up into rounds with different alignment parameters
- Each round can have an arbitrary number of iterations
- Each round employs a multilevel refinement [angular sampling scheme](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Multilevel_refinement)
- High and low pass thresholds (in Fourier pixels) define which spatial frequencies are aligned
- Shifts are x, y, z shifts in the reference frame of each experimental particle
- The evolution of particle positions can be restricted using the `shift limiting way` option.


You can get a depiction of your current angular search parameters from the `Angles -> Show sketch of scanning angles -> Round X` menu options.

![scanning angles image](simple-alignment.assets/scanning-angles.gif)

### Computational parameters
Computational parameters are used to tell the projects what it needs to know about the computing environment where it will be run.

Click `computing environment` from the `dcp` GUI, a new window will open in which parameters can be edited.


#### Hardware
````{margin}
```{tip}
Running projects in the `standalone` modus leaves your `Dynamo` shell free for designing projects, making masks and performing other analyses.
```
````

First, choose the hardware on which you will be running your alignment project. We typically use `GPU (standalone)`.

```{attention}
If running in a GPU modus, you should use only one CPU core in this box!
```

##### (optional) specifying GPUs
Specify the GPU identifiers for GPUs you would like to use for alignment. These are typically enumerated from 0.

e.g. for a 4 GPU system, set this to `0,1,2,3`

Leave the motor as `spp` (this stands for sub-pixel precision).

#### MPI
This section can be used to select a cluster submission script which works with your system. More info [here](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/MPI_Cluster).

#### Parallelized averaging step
This section allows a user to specify how many cores they would like to use for the 'averaging' step between each iteration of subtomogram averaging.
This should be set to the number of logical (not hyperthreaded) cores available on the system used for executing the project.

## Unfolding the project
Unfolding a project means getting it ready to run on your system. If executing on a remote system, the project should be unfolded on that system.

To unfold a project, first hit `check`, then `unfold` from the control section of the `dcp` GUI.

This will create a file `<my_new_project>.exe` or `<my_new_project.m>` depending on whether the project will run in the standalone or the `MATLAB` environment.

## Running the project
If running a project in the `MATLAB` modus, just type this in your `Dynamo` shell:
```matlab
run <my_new_project>.m` 
```

If running using the `standalone`, you first have to activate `Dynamo` in the shell. Usually this is achieved by running:

```bash
source /path/to/dynamo/installation/dynamo_activate_linux_shipped_MCR.sh

./<my_new_project>.exe
```

## Looking at the results
Hitting the `show` button from the `Results` row of the `dcp` GUI opens up a new window for looking at the results of an alignment project.

Hitting the `progress` button will tell you the current status of the alignment project.

From the results GUI, averages and associated particle metadata can be visualised in various tools. You can also open your maps directly in other packages such as `ChimeraX`.

Visualising particle positions and orientations can also be useful to check that an alignment procedure is behaving as you expect.
