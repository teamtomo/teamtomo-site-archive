# Particle picking and initial model generation

The tomograms are reconstructed and ready for further analysis. Warp includes a template matching procedure, but what if we don't know what our object of interest looks like yet? In this section we will:
- generate an initial model of the HIV-1 CA-SP1 hexamer *ab initio*
- use that model to find particles in all of our tomograms

In biological systems, particles often have a spatial relationship with an underlying supporting geometry such as a membrane, filament or vescicle.

Exploiting this prior knowledge about the geometry of a system is often useful in subtomogram averaging, reducing both the computational burden and  the ability of particles to end up in obviously wrong positions after an iterative refinement procedure. 

In the following sections, we will design and implement an approach to obtain a reconstruction of these lattices, employing prior knowledge about the geometry of the system to drive the subtomogram averaging procedure and enforce a correct final solution. We aim to demonstrate some key principles for producing produce accurate reconstructions from your data *ab initio*.

## What do we know and how can we use it?

Question worth asking yourself repeatedly when designing an approach to a subtomogram averaging problem are *"what do we know?"*  and *"how can we make use of this?"*

At this stage, looking at the deconvolved tomograms in any visualisation package (3dmod, dynamo_tomoslice, FIJI, napari) allows us to see that:
- the VLPs are nearly spherical
- proteins on the surface of the VLPs form a hexagonal lattice parallel to the membrane
- the lattice spacing is roughly 7.5 nm

Can we use this information to help us in our efforts to reconstruct this lattice structure? Absolutely! 
- We can generate initial estimates for particle positions as points on a sphere centered on a VLP with the correct radius. These positions will be incorrect but particles extracted at these positions will contain our lattice structure. 
- The lattice is always parallel to the membrane, imparting an orientation normal to the surface of the sphere  onto each particle will provide a consistent estimate for the initial orientation of the particles in the lattice.

- We know that we have a lattice spacing of roughly 7.5 nm, to be sure that we will not miss any particles in the lattice we should oversample the sphere relative to this spacing - we can always remove any duplicates later. 

Dynamo contains many geometrical modelling tools which can help with these geometrical approaches to subtomogram averaging projects. We will make use of a limited subset of these tools in this tutorial, for an overview of the available geometrical models please see [here](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Model#Types_of_models). Becoming familiar with the available tools and thinking about how you can use the geometry of your system to your advantage will help with many subtomogram averaging projects. Below, we used `dynamo_tomoslice` to  estimate the lattice spacing in our tomograms, this tool will be introduced shortly.

![particle distance](README.assets/particle-distance.png)

## Generating a Dynamo catalogue for particle picking

We now need to decide on a system for managing our reconstructed tomograms and annotations. A Dynamo catalogue is a database which facilitates the management of tomography data, including annotations and subsequent particle extraction. 

We have provided a function `warp2catalogue` in the `autoalign_dynamo` package which will setup a catalogue from your Warp tomograms and their deconvolved counterparts. The catalogue is set up in such a way that any visualisation of the tomograms from the catalogue will display the deconvolved volumes but particles are extracted from the unfiltered volumes which are suitable for alignment and averaging experiments.

The function takes two arguments: the warp reconstruction directory and the pixel spacing in the reconstructions.

Let's create a new `dynamo` folder in the root directory, and navigate to it in Matlab. Then, we run:
```matlab
warp2catalogue('../frames/reconstruction', 10)
```

This will generate the catalogue with the name `warp_catalogue` inside the `dynamo` directory. To open the catalogue manager in dynamo, run
```matlab
dcm warp_catalogue
```

From the catalogue manager which opens up, tomograms can be opened in an interactive browser called `dynamo_tomoslice` by first selecting the tomogram of interest then using the `Selected volume -> Open full volume with tomoslice` menu options.

At this point we recommend getting comfortable with basic manipulation of the tomoslice viewer. As you can probably tell by the number of buttons and menus, this viewer contains many powerful tools. Don't be scared! Read the [wiki page](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Dtmslice) describing how to use it. Once you feel comfortable, move onto the next section where we will annotate our VLPs to provide initial positions and orientations for subtomogram averaging.


## VLP annotation

### Defining our approach

We need to annotate many spherical VLPs within each tomogram. Whilst we could achieve this by annotating each sphere as a vesicle model directly, the workflow for defining vesicle models from `dynamo_tomoslice` requires defining many points for each vesicle model. This approach is robust, but not especially quick if we have many annotations to make. 

Instead, we will take a shortcut - spheres can be completely defined by only two values, their centre point and their radius. We will create a `dipoleSet` model in each tomogram to annotate the centres and edge points of many VLPs quickly in just one model, then convert these `dipoleSet` models into oversampled vesicles with a function which we provide. 

### Creating dipole set models

Open up the catalogue `warp_catalogue` we just created using the `dcm` command. Select the first tomogram, then in the menu choose `View volume -> full tomogram file in tomoslice`.

We need to create our `dipoleSet` model. To create the model, use the `Model pool -> Create a new model in pool (choose type) -> Dipole set` menu options. The active model is now set to the new `dipoleSet` model and we are ready to annotate our VLPs.

Some of the shortcuts we need to know are:
- `c` to set a center point for the current dipole
- `n` to set a north point for the current dipole
- `Enter` to save the current dipole and move to the next one

> For a full guide on how to interact with `dipoleSet` models, check out the relevant [wiki page](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Dipole_set_models).

Move the slice in the tomogram and roughly pick the center point of each VLP by moving the cursor to that point and pressing `c`. Then, a point on the surface of the same vescicle and press `n` to define an edge point. A surface rendering of the defined sphere will appear; move the slice and look at the VLP from different orientations to make sure that the sphere matches the VLP well.

While this is trivial for intact vescicles, you will find that several vescicles are damaged or incomplete. As long as they retain a mostly spherical shape, and roughly more than half the capsid is present, we should pick them. We will attempt to remove any non-particles from the data based on geometrical constraints at a later step.

![dipole picking](https://i.ibb.co/N1K4GW1/dipole-picking.png)

With this guide, we provide a short video of this `dipoleSet` model picking on `TS_03`, available as `dipoles_picking.mp4`.

Once all the vescicles in a tomogram are picked, save the model by clicking on `Active Model -> Save active model into catalogue (disk)` or clicking the floppy disk icon in the menu bar.

Close the tomoslice window and repeat the process for each tomogram.

> If Dynamo asks what to do with the model in pool memory and you already saved the model, choose to delete it. Dynamo may show some elements of the previous `dipoleSet` model when opening a new tomogram. This is a visualisation bug, and does not affect the creation of a new model.

### Convert dipoleSet models into oversampled Vesicle models

Once all the dipole models are picked, we can convert them into oversampled `Vesicle` models. For this, we will use the `dipoles2vescicles.m` script provided with this tutorial. The script generates a Dynamo `Vescicle` model for every dipole in each `dipoleSet` model in a catalogue.

> We urge interested readers to look at the provided scripts rather than running them blindly; this will help when it comes to tackling the problems posed by your own data!

To generate the `Vesicle` models, from the `dynamo` directory run:
```matlab
dipoles2vescicles('warp_catalogue', 7.5)
```


## First alignments in Dynamo

Now that the Dynamo catalogue contains initial estimates for the positions and orientations of our particles, we need to obtain an initial model of our lattice structure which will later allow us to find more accurate estimates of the positions and orientations of our particles for the whole dataset. For this, we will work on a small subset of the VLPs.

> Working on a small subset initially allows you to move quickly, testing lots of different approaches and optimising your approach. How small this subset should be will depend on the quality of your data, your initial particle picking and your object of interest. 

For these VLPs and with data of such good quality, two vesicles is more than enough for generating a good initial model.

When choosing an initial subset, it can be a good idea to choose VLPs with different defoci. This ensures that nodes of the CTF are at different spatial frequencies within the subset and thus no region of Fourier space should be particularly undersampled. The Jiang lab at Purdue University have a CTF simulation [web app](https://ctf-simulation.herokuapp.com/) which is useful for visualising the effect of defocus on the CTF.

> Choosing a subset which contains all available views of the particle is also important, ensuring maximum coverage of Fourier space in a resulting reconstruction

From the `Overview` tab in Warp, we quickly see that `TS_01` and `TS_03` have significanlty different defoci, so we choose to use one vescicle from each of these tomograms.

### Extracting a subset of particles

To extract particles from the selected tomograms, open the dynamo catalogue manager by running `dcm` from the `dynamo` directory. Then load the `warp_catalogue` and select `TS_01` and `TS_03`. In the menu, choose `Crop particles -> Open Volume List Manager` to open a list of all models.

From the `selection` tab at the bottom of the window, we `pick` one `Vesicle` model from each volume. Then, choose a file name in the `Picked Volume list` (we use `inimodel.vll`) and make sure that the sidelength is set to 32.

> A box sidelength of 32 corresponds to a 320$\AA$. While this is much larger than the expected 75$\AA$ inter-particle distance, signal from neighbouring particles in lattices can help to drive correct alignments at the beginning of a project. When working at smaller pixel sizes a bigger box can also help to [prevent CTF aliasing](???)

To extract subvolumes, click the `create list` button to prepare a [volume list file](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Volume_list_file) with the necessary information for particle extraction. Following this, clicking `Crop Particles` will open another GUI from which we can crop particles. 

In the newly opened window, we select `data folder in dBoxes`, choose a name for the data folder then press the `start cropping` button. This will take several minutes.

> Choosing to save the data as a dBoxes folder speeds things up when setting up subtomogram averaging projects in Dynamo, some checks run fairly slowly if there are too many files in one folder

% screenshots here

### The alignment project

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

#### Assessing the results
We can look at the result of our first alignment project using tools from the `dcp` GUI under show. Alternatively, the file containing the average can be found at `dynamo/inimodel/results/ite_0004/averages/average_ref_001_ite_0004.em` and visualised with any volume visualisation tool.

In contrast to our previous reconstruction from particles with initial estimates for positions and orientations, in this map we clearly see a hexagonal lattice starting to take shape, containing 2-, 3- and 6-fold symmetry axes.

![first aligned map](https://i.ibb.co/wgby9P2/first-align-all.png)

In order to take advantage of the highest symmetry order present in the structure during refinement we first need to recenter the average on its 6-fold symmetry axis and align that axis along the z axis of our volume.

> By convention, rotational symmetry axes in electron microscopy software are aligned along the Z axis of the volume

% Add a note here about how to visualise results, including positions and orientations within dynamo using dpktbl.plots.sketch(t)

#### Aligning and centering the 6-fold symmetry axis in the initial model
To center and align the 6-fold symmetry axis, we will use a script provided with this tutorial, `align_symmetry_axis.m`. The script generates a synthetic template of the lattice with the 6-fold symmetry axis centered and aligned along the z-axis. The result of the alignment project is then aligned to this synthetic template and C6 symmetry is applied to produce our final initial model with the symmetry axis correctly aligned.

To run the script, open `dynamo/inimodel/results/ite_0004/averages` in Matlab. Copy the script into this directory, and execute it by running `align_symmetry_axis`. Once the script has finished, compare the initial average, the template, the aligned average and the symmetrised aligned average to check that the alignment worked as intended.

%% comparison of all 4 volumes here, Z and Y projections

![aligned to z ](https://i.ibb.co/Jxd9nXc/aligned-to-z.png)

Now that we have an initial model with the 6-fold symmetry, we can use this in an alignment project with particles from all of the VLPs to obtain good estimates for particle positions and orientations for the whole dataset.

## Finding particles for every VLP

*"What do we know and how can we use it?"*

We now have 

- initial estimates for the particle positions and orientations on the surface of every VLP 

- a good initial model centered on the 6-fold symmetry axis of the lattice structure. 

We can use this information to run a one iteration subtomogram averaging project. This should allow us to obtain a good set of particle positions and orientations for the dataset which we can later use for higher resolution reconstruction.

### Particle extraction

As for the initial model generation step, we need to extract our particles prior to alignment, this time from all VLPs rather than just a subset. Extract particles from `dcm`  as before, selecting all `Vesicle` models.

% screenshot of extraction GUI

### Particle alignment
Next we set up an alignment project using `dcp` where the aim is to align each oversampled initial particle position to the closest real particle position in the lattice. The important parameters when setting up this project are:

1. Data should be the extracted data folder for the whole dataset
2. Table should be the cropping table derived when extracting the data, found in the data folder
3. Template should now be the aligned, symmetrised initial model
     `dynamo/inimodel/ite_0004/averages/average_aligned_along_z_c6.em`.
4. We only want to run for one iteration

> Now that we're working with the full dataset, calculations take significantly longer. Because our initial model is good one iteration of alignment should allow us to see the lattice structure appear in the particle positions.

1. We only want to perform local in plane and out of plane angular searches

> We are already fairly sure about our out of plane angles because they come from our `Vesicle` models. The in plane searches can be limited because of the C6 symmetry of the reference

1. We should adjust the shifts so that particles can only move half of the lattice spacing in the x and y direction

> We expect to find a lattice of particles with roughly 7.5 nm spacing. If we allow each particle to shift a maximum of 4nm in each direction it should be guaranteed to find the closest true position in the lattice but cannot move too far. This maximises the chances of finding all lattice positions from the beginning.

1. We should allow the particles to shift more in z than in x and y to account for any errors when defining our `Vesicle` models.

% numerical parameter screenshot here

Once the parameters are all set, run the project from the command line as before. This will take significantly longer!

% add visualisation of results including particle positions using dpktbl.plots.sketch(), note presence of duplicates and bad regions

% add section visualising results again and making conclusions based on the experiment that was done - teach the reader to get into the habit of interacting with the data, not just plugging it into the program and seeing the reconstruction that comes out

## Cleaning the dataset based on geometrical constraints

To isolate a good subset of particles in lattices we will use three short scripts provided with this tutorial. 

> The provided scripts are just a few lines long, and are given for convenience and illustration purposes. You are encouraged to read them and modify them for your own purposes

% scripts should be provided as files but also copies in the guide directly to force readers to engage with the scripts at least a little bit

The first cleaning step we should take is removing duplicate particles. To do so, we will use `remove_duplicates.m`.
Open MATLAB in `dynamo/findparticles/results/ite_0001/averages`, then run:

```matlab
remove_duplicates
```

This will create a new table called `result_10Apx_nodup.tbl`, reducing clusters of multiple particles within 4 pixels (half the distance we measured earlier) to a single particle.

The next step is to remove particles that don't belong to the lattice. To do so, first run:
```matlab
check_radial_distribution
```

This will open a plot of the radial distribution of neighbouring particles for the whole dataset. Here, we can see a high peak at around 7.5 $px$, and periodic peaks after that.

![radial distribution](https://i.ibb.co/gJ0K1Q0/radial-distance.png)

This confirms the previously measured interparticle distance and the fact that most particles slid into ordered positions in the lattice. We can use the first peak to select against particles that don't conform to this distribution. The next script, `subset_table_based_on_neighbours.m`, removes all particles that don't have at least 3 neighbours in the radial shell at distance 7.5 $px$. To use it, run:
```matlab
subset_table_based_on_neighbours
```

> When finished, the script will open a viewer to inspect the table before and after the processing. Switching to a less clean dataset (for example `TS_43`) will make it clear that most bad particles were removed.

The final output is a new table called `result_10Apx_nodup_neighbourcleaning.tbl` which contains only references to the particles that we selected.


## Next step
click [here](relion.md)
