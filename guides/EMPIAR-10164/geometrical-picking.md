# Geometrical particle picking

The tomograms are reconstructed and ready for further analysis. Warp includes a template matching procedure, but what if we don't know what our object of interest looks like yet? 

In biological systems, particles often have a spatial relationship with an underlying supporting geometry such as a membrane, filament or vescicle.

Exploiting this prior knowledge about the geometry of a system is often useful in subtomogram averaging, reducing both the computational burden and the risk of particles ending up in obviously wrong positions after an iterative refinement procedure.

In the following sections, we will design and implement an approach to obtain a reconstruction of these lattices, employing prior knowledge about the geometry of the system to drive the subtomogram averaging procedure and enforce a correct final solution. We aim to demonstrate some key principles for producing accurate reconstructions from your data *ab initio*.

## What do we know and how can we use it?

Questions worth asking yourself repeatedly when designing an approach to a subtomogram averaging problem are *"what do we know?"*  and *"how can we make use of this?"*

At this stage, looking at the deconvolved tomograms in any visualisation package (3dmod, dynamo_tomoslice, FIJI, napari) allows us to see that:
- the VLPs are nearly spherical
- proteins on the surface of the VLPs form a hexagonal lattice on the membrane
- the lattice spacing is roughly 7.5 nm

````{margin}
```{note}
While the lattice spacing is about 7.5 nm, to be sure that we don't miss any particles in the lattice we will oversample the sphere relative to this spacing - we can always remove any duplicates later.
```
````

We can use this information to help us in our efforts to reconstruct this lattice structure:
- We can generate initial estimates for particle positions as points on a sphere centered on a VLP with the correct radius. These positions will be incorrect but particles extracted at these positions will contain our lattice structure. 
- The lattice is always parallel to the membrane, imparting an orientation normal to the surface of the sphere  onto each particle will provide a consistent estimate for the initial orientation of the particles in the lattice.

Dynamo contains many geometrical modelling tools which can help with these geometrical approaches to subtomogram averaging projects. We will make use of a limited subset of these tools in this tutorial, for an overview of the available geometrical models please see [here](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Model#Types_of_models). Becoming familiar with the available tools and thinking about how you can use the geometry of your system to your advantage will help with many subtomogram averaging projects. Below, we used `dynamo_tomoslice` to  estimate the lattice spacing in our tomograms, this tool will be introduced shortly.

![particle distance](README.assets/particle-distance.png)

## Generating a Dynamo catalogue for particle picking

We now need a system for managing our reconstructed tomograms and annotations. A Dynamo catalogue is a database which facilitates the management of tomography data, including annotations and subsequent particle extraction. 

We have provided a function `warp2catalogue` in the `autoalign_dynamo` package which will setup a catalogue from your Warp tomograms and their deconvolved counterparts. The catalogue is set up in such a way that any visualisation of the tomograms from the catalogue will display the deconvolved volumes but particles are extracted from the unfiltered volumes which are suitable for alignment and averaging experiments.

The function takes two arguments: the warp reconstruction directory and the pixel spacing of the reconstructed tomograms.

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

````{margin}
```{admonition} See also
:class: seealso
For a full guide on how to interact with `dipoleSet` models, check out the relevant [wiki page](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Dipole_set_models).
```
````

Some of the shortcuts we need to know are:
- `c` to set a center point for the current dipole
- `n` to set a north point for the current dipole
- `Enter` to save the current dipole and move to the next one

Move the slice in the tomogram and roughly pick the center point of each VLP by moving the cursor to that point and pressing `c`. Then, a point on the surface of the same vescicle and press `n` to define an edge point. A surface rendering of the defined sphere will appear; move the slice and look at the VLP from different orientations to make sure that the sphere matches the VLP well.

While this is trivial for intact vescicles, you will find that several vescicles are damaged or incomplete. As long as they retain a mostly spherical shape, and roughly more than half the capsid is present, we should pick them. We will attempt to remove any non-particles from the data based on geometrical constraints at a later step.

![dipole picking](https://i.ibb.co/N1K4GW1/dipole-picking.png)

````{margin}
```{admonition} Tip
:class: tip
To see a short demo on how we picked on `TS_03` and a more in-depth explanation on the `tomoslice` viewer, check out [this mini tutorial]().
```
````

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


