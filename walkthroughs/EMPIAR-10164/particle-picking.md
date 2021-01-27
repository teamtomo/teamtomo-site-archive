# Finding particles on every VLP

*"What do we know and how can we use it?"*

We now have 

- initial estimates for the particle positions and orientations on the surface of every VLP 
- a good initial model centered on the 6-fold symmetry axis of the lattice structure. 

We can use this information to run a one iteration subtomogram averaging project. This should allow us to find a good set of particle positions and orientations, centered on the 6-fold symmetry axes, which we can later use for higher resolution reconstruction.

## Particle extraction

As for the initial model generation step, we need to extract our particles prior to alignment, this time from all VLPs rather than just a subset. Extract particles from `dcm`  as before, selecting all `Vesicle` models.

% screenshot of extraction GUI

## Particle alignment
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

