# Initial model generation

Now that the Dynamo catalogue contains initial estimates for the positions and orientations of our particles, we need to obtain an initial model of our lattice structure which will later allow us to find more accurate estimates of the positions and orientations of our particles for the whole dataset. For this, we will work on a small subset of the VLPs.

````{margin}
```{tip}
Working on a small subset initially allows you to move quickly, testing lots of different approaches and optimising your approach. How small this subset should be will depend on the quality of your data, your initial particle picking and your object of interest. 
```
````

For these VLPs and with data of such good quality, two vesicles is more than enough for generating a good initial model.

When choosing an initial subset, it can be a good idea to choose VLPs with different defoci. This ensures that nodes of the CTF are at different spatial frequencies within the subset and thus no region of Fourier space should be particularly undersampled. The Jiang lab at Purdue University have a CTF simulation [web app](https://ctf-simulation.herokuapp.com/) which is useful for visualising the effect of defocus on the CTF.

Choosing a subset which contains all available views of the particle is also important, ensuring maximum coverage of Fourier space in a resulting reconstruction

From the `Overview` tab in Warp, we quickly see that `TS_01` and `TS_03` have significantly different defoci, so we choose to use one vescicle from each of these tomograms.

(hiv:extract-subset)=
## Extracting a subset of particles

````{margin}
```{note}
A box sidelength of 32 corresponds to a 320$Å$. While this is much larger than the expected 75$Å$ inter-particle distance, signal from neighbouring particles in lattices can help to drive correct alignments at the beginning of a project. When working at smaller pixel sizes a bigger box can also help to avoid [CTF aliasing](TODO).
```
````

Extract particles from your `Dynamo` catalogue with a sidelength of `32` following [this mini-tutorial](../../mini-tutorials/dynamo/extract-from-catalogue). To make things faster, for now we can extract just from the volumes that we are interested in (`TS_01` and `TS_03`), and call this volume list `inimodel.vll`).

```{warning} Don't forget!
We still need to extract all the particles for later steps. Once this extraction is done, start another one with the whole dataset!
```

## Aligning the particles

Once the particle volumes are extracted for our two VLPs, we want to perform a first rough alignment to see how the particles align and average. 

We run `dcp` from MATLAB to open the "Dynamo current project" GUI. This GUI is designed to be used in a sequential way: we will need to provide a few parameters before launching the project.

For a full tutorial on how to setting up a simple subtomogram averaging project in Dynamo, click [here](../../mini-tutorials/dynamo/alignment-setup).

In our case, we set it up as follows:

`Project`:
: `inimodel`

`particles`
: the previously generated `inimodelData.Boxes` (or otherwise named) directory.

`table`
: the `crop.tbl` file we generated earlier together with the Boxes directory. When we cropped particles in the Dynamo catalogue, it created this metadata file for us and puts it inside the data folder. Click `look inside data folder` and pick the `crop.tbl` file.

`template`
: since we don't have one, generate a random one using a `randomly chosen set of particles`. 500 is a good starting point. This will generate a reconstruction from 500 particles using our initial particle orientation estimates from the `crop.tbl` file, originally from the `Vesicle` models. While we don't expect to see any detailed structure in this map, but it's worth checking that it matches what we expect to see. If you right click on the file path at the top of the template GUI, you can choose to `[view]` the volume. Our initial picking contained no knowledge about the specific positions of each particle within the lattice. Because of this, we expect to see a curved, membrane like density and blurred density for the lattice proteins in the average.

![first template](ini-model.assets/first-template-all.png)


`masks`
: `Use default masks` will give us appropriate masks at this stage that cover the full extent of our 32px box. At this stage, we aren't very sure of our particle positions and orientations as they haven't undergone any alignment. We want our mask to include the whole box so that signal from multiple neighbouring particles in the lattice can help to drive initial alignments.


````{margin}
```{note}
Press `Alt` when a parameter is selected for a detailed description.
```
````

`numerical parameters`
: set the numerical parameters for the alignment procedure as shown below. Check out the [mini-tutorial] for a more in-depth explanation. At this stage, we don't enforce symmetry during refinement. We expect that any symmetry present should appear in an initial average. The assumption of symmetry is a useful tool but it reduces our ability to discern any asymmetries that may be present in the reconstruction. It should be applied only when you are sure that your object is symmetric and the possibility of unresolved asymmetry should be kept in mind.

% images need to be a bit cleaner I think

% need to add screenshot of alignment parameters here

![alignment parameters](TODO)

`computing environment`
: this will depend on your computing environment, including number of available CPUs/GPUs. We typically run projects in the `gpu_standalone` modus on 4 GPUs. Running in the standalone modus allows you to continue with other work in the matlab shell while the alignment project runs. In this modus, the number of CPU cores should be 1. The number of CPU cores used during averaging can be changed to the number of logical CPU cores on your machine. Specific GPUs can be selected by their index as seen in `nvidia-smi`.

`check` and `unfold`
: run a sanity `check` to make sure the project seems correctly setup, then `unfold` to prepare an executable for the alignment project. If running a project on a remote machine without graphical access, a project can be set up locally and sent to the remote machine as a tarball. For information on this, please see [this wiki page](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Tarring_projects).


We can now run the executable. To do so, open the `dynamo` directory in a terminal and run:
```bash
source $DYNAMO_ROOT/dynamo_activate_linux_shipped_MCR.sh
```
to prepare the environment. Then, simply execute:
```bash
./inimodel.exe
```

````{margin}
```{tip}
You can track the progress of the project from the `dcp` GUI by clicking on `progress`.
```

% Lots more screenshots needed here

## Assessing the results
We can look at the result of our first alignment project using tools from the `dcp` GUI under show. Alternatively, the file containing the average can be found at `dynamo/inimodel/results/ite_0004/averages/average_ref_001_ite_0004.em` and visualised with any volume visualisation tool.

In contrast to our previous reconstruction from particles with initial estimates for positions and orientations, in this map we clearly see a hexagonal lattice starting to take shape, containing 2-, 3- and 6-fold symmetry axes.

![first aligned map](ini-model.assets/first-aligned-all.png)

````{margin}
```{note}
By convention, rotational symmetry axes in electron microscopy software are aligned along the Z axis of the volume.
```
````
In order to take advantage of the highest symmetry order present in the structure during refinement we first need to recenter the average on its 6-fold symmetry axis and align that axis along the z axis of our volume.

% Add a note here about how to visualise results, including positions and orientations within dynamo using dpktbl.plots.sketch(t)

## Aligning and centering the 6-fold symmetry axis
To center and align the 6-fold symmetry axis, we will use a script provided with this tutorial, `align_symmetry_axis.m`. The script generates a synthetic template of the lattice with the 6-fold symmetry axis centered and aligned along the z-axis. The result of the alignment project is then aligned to this synthetic template and C6 symmetry is applied to produce our final initial model with the symmetry axis correctly aligned.

To run the script, open `dynamo/inimodel/results/ite_0004/averages` in Matlab. Copy the script into this directory, and execute it by running `align_symmetry_axis`. Once the script has finished, compare the initial average, the template, the aligned average and the symmetrised aligned average to check that the alignment worked as intended.

%% comparison of all 4 volumes here, Z and Y projections

![aligned to z ](ini-model.assets/aligned-to-z.png)

Now that we have an initial model with the 6-fold symmetry, we can use this in an alignment project with particles from all of the VLPs to obtain good estimates for particle positions and orientations for the whole dataset.
