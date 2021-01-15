# Initial model generation

Now that the Dynamo catalogue contains initial estimates for the positions and orientations of our particles, we need to obtain an initial model of our lattice structure which will later allow us to find more accurate estimates of the positions and orientations of our particles for the whole dataset. For this, we will work on a small subset of the VLPs.

> Working on a small subset initially allows you to move quickly, testing lots of different approaches and optimising your approach. How small this subset should be will depend on the quality of your data, your initial particle picking and your object of interest. 

For these VLPs and with data of such good quality, two vesicles is more than enough for generating a good initial model.

When choosing an initial subset, it can be a good idea to choose VLPs with different defoci. This ensures that nodes of the CTF are at different spatial frequencies within the subset and thus no region of Fourier space should be particularly undersampled. The Jiang lab at Purdue University have a CTF simulation [web app](https://ctf-simulation.herokuapp.com/) which is useful for visualising the effect of defocus on the CTF.

> Choosing a subset which contains all available views of the particle is also important, ensuring maximum coverage of Fourier space in a resulting reconstruction

From the `Overview` tab in Warp, we quickly see that `TS_01` and `TS_03` have significanlty different defoci, so we choose to use one vescicle from each of these tomograms.

## Extracting a subset of particles

To extract particles from the selected tomograms, open the dynamo catalogue manager by running `dcm` from the `dynamo` directory. Then load the `warp_catalogue`.

Select `TS_01` and `TS_03`. In the menu, choose `Crop particles -> Open Volume List Manager` to open a list of all models.

From the `selection` tab at the bottom of the window, we `pick` one `Vesicle` model from each volume. Then, choose a file name in the `Picked Volume list` (we use `inimodel.vll`) and make sure that the sidelength is set to 32.

```{note}
A box sidelength of 32 corresponds to a 320$\AA$. While this is much larger than the expected 75$\AA$ inter-particle distance, signal from neighbouring particles in lattices can help to drive correct alignments at the beginning of a project. When working at smaller pixel sizes a bigger box can also help to avoid [CTF aliasing](???)
```

To extract subvolumes, click the `create list` button to prepare a [volume list file](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Volume_list_file) with the necessary information for particle extraction. Following this, clicking `Crop Particles` will open another GUI from which we can crop particles. 

In the newly opened window, we select `data folder in dBoxes`, choose a name for the data folder then press the `start cropping` button. This will take several minutes.

> Choosing to save the data as a dBoxes folder speeds things up when setting up subtomogram averaging projects in Dynamo, some checks run fairly slowly if there are too many files in one folder

% screenshots here

## Aligning the particles

Once the particle volumes are extracted for our two VLPs, we want to perform a first rough alignment to see how the particles align and average. 

We run `dcp` from MATLAB to open the "Dynamo current project" GUI. This GUI is designed to be used in a sequential way: we will need to provide a few parameters before launching the project.

1. `Project`: choose a name for the project
   Write `inimodel`, then press `Enter` and `Create a new project`.
2. `particles`: select the data folder containing the previously extracted volumes
   Click `browse` and select the `inimodelData.Boxes` directory.
3. `table`: choose a Dynamo table file containing particle metadata such as positions and orientations
   When we cropped particles in the Dynamo catalogue, it created this metadata file for us and puts it inside the data folder. Click`look inside data folder` and pick the `crop.tbl` file.
4. `template`: choose an initial template for alignment
   We currently don't have a template. In the `I want to create a template` section, select `use a randomly chosen set of particles`, set the number to `500` and click `average data` to compute an initial template.

> This will generate a reconstruction from 500 particles using our initial particle orientation estimates from the `crop.tbl` file, originally from the `Vesicle` models. While we don't expect to see any detailed structure in this map, it is worth checking that it matches what we expect to see. If you right click on the file path at the top of the template GUI, you can choose to `[view]` the volume. Our initial picking contained no knowledge about the specific positions of each particle within the lattice. Because of this, we expect to see a curved, membrane like density and blurred density for the lattice proteins in the average.

![first template](https://i.ibb.co/dM5Dqt5/first-template-all.png)

% images need to be a bit cleaner I think

5. `masks`: select masks for each step of the procedure.
    Dynamo offers lots of flexibility in the choice and use of masks during the alignment procedure. In this case `Use default masks` will calculate appropriate masks at this stage covering the full extent of our 32px box.

> At this stage, we aren't very sure of our particle positions and orientations as they haven't undergone any alignment. We want our mask to include the whole box so that signal from multiple neighbouring particles in the lattice can help to drive initial alignments.

6. `numerical parameters`: set the numerical parameters for the alignment procedure.
    This section allows us to define many important numerical parameters for an alignment project. Dynamo alignment projects can be split into several rounds which will be executed one after the other. Within each round parameters include number of iterations, angular search ranges, shift limits, high- and low-pass filter limits, symmetry operators to apply to the reference and more.

> At this stage, we don't enforce symmetry during refinement. We expect that any symmetry present should appear in an initial average. The assumption of symmetry is a useful tool but it reduces our ability to discern any asymmetries that may be present in the reconstruction. It should be applied only when you are sure that your object is symmetric and the possibility of unresolved asymmetry should be kept in mind.

> Press `Alt` when a parameter is selected for a detailed description.

7. `computing environment`: the computing environment on which the alignment project will run

    This will depend on your computing environment, including number of available CPUs/GPUs.

> We typically run projects in the `gpu_standalone` modus on 4 GPUs. Running in the standalone modus allows you to continue with other work in the matlab shell while the alignment project runs. In this modus, the number of CPU cores should be 1. The number of CPU cores used during averaging can be changed to the number of logical CPU cores on your machine. Specific GPUs can be selected by their index as seen in `nvidia-smi`.


8. `check` runs a sanity check to make sure the project seems correctly setup, `unfold` prepares an executable for the alignment project.

> If running a project on a remote machine without graphical access, a project can be set up locally and sent to the remote machine as a tarball. For information on this, please see the following [wiki page](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Tarring_projects)


9. We can now run the executable.To do so, open the `dynamo` directory in a terminal and run:
```bash
source $DYNAMO_ROOT/dynamo_activate_linux_shipped_MCR.sh
```
to prepare the environment. Then, simply execute:
```bash
./inimodel.exe
```

> You can track the progress of the project from the `dcp` GUI by clicking on `progress`.

% Lots more screenshots needed here

## Assessing the results
We can look at the result of our first alignment project using tools from the `dcp` GUI under show. Alternatively, the file containing the average can be found at `dynamo/inimodel/results/ite_0004/averages/average_ref_001_ite_0004.em` and visualised with any volume visualisation tool.

In contrast to our previous reconstruction from particles with initial estimates for positions and orientations, in this map we clearly see a hexagonal lattice starting to take shape, containing 2-, 3- and 6-fold symmetry axes.

![first aligned map](https://i.ibb.co/wgby9P2/first-align-all.png)

In order to take advantage of the highest symmetry order present in the structure during refinement we first need to recenter the average on its 6-fold symmetry axis and align that axis along the z axis of our volume.

> By convention, rotational symmetry axes in electron microscopy software are aligned along the Z axis of the volume

% Add a note here about how to visualise results, including positions and orientations within dynamo using dpktbl.plots.sketch(t)

## Aligning and centering the 6-fold symmetry axis
To center and align the 6-fold symmetry axis, we will use a script provided with this tutorial, `align_symmetry_axis.m`. The script generates a synthetic template of the lattice with the 6-fold symmetry axis centered and aligned along the z-axis. The result of the alignment project is then aligned to this synthetic template and C6 symmetry is applied to produce our final initial model with the symmetry axis correctly aligned.

To run the script, open `dynamo/inimodel/results/ite_0004/averages` in Matlab. Copy the script into this directory, and execute it by running `align_symmetry_axis`. Once the script has finished, compare the initial average, the template, the aligned average and the symmetrised aligned average to check that the alignment worked as intended.

%% comparison of all 4 volumes here, Z and Y projections

![aligned to z ](https://i.ibb.co/Jxd9nXc/aligned-to-z.png)

Now that we have an initial model with the 6-fold symmetry, we can use this in an alignment project with particles from all of the VLPs to obtain good estimates for particle positions and orientations for the whole dataset.

