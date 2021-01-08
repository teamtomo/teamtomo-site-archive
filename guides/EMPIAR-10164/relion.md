# Particle pose optimisation in RELION

Now that we have a set of particles that appears to be free of duplicates and matches our geometrical understanding of the system we can proceed to refine our particle positions and orientations with the aim of producing a higher resolution average. 

In this section, we will 

- Extract particles in Warp at 5Apx
- Align these particles by subtomogram averaging in RELION
- Extract particles in Warp at 1.6Apx
- Align these particles by subtomogram averaging in RELION

> Subtomogram averaging becomes very slow when performing refinements with lots of particles in larger boxes. Stepping the pixel size down gradually allows us to move more quickly and react to any problems which may come up when working on more complex data.

> We extracted at 1.6Apx rather than 1.35Apx due to memory limitations. Warp employs a defocus dependent mechanism to reduce the effects of CTF aliasing, the large number of particles per field-of-view is particularly demanding at such a small pixel size and can lead to memory issues. Unless extracting at a very small pixel size, you are unlikely to encounter these issues when working with your own data.

### Extract subtomograms in Warp at 5$\AA/px$

#### Generate compatible metadata

We need to convert our particle positions and orientations in the dynamo metadata into a format Warp understands, we will use the `dynamo2warp` script provided by the `dynamo2m` package. The script takes a `.tbl` file (which we generated at the end of the previous section) and a table map file. The table map file contains a mapping from particle indexes to file names, to match to the column 20 of the `.tbl` file. In our case, this file is located in `dynamo/oversampledData.Boxes/indices_column20.doc`.

In a terminal, run:
```bash
dynamo2warp -i result_10Apx_nodup_neighbourcleaning.tbl -tm ../../../../oversampledData.Boxes/indices_column20.doc -o result_15Apx_nodup_neighbourcleaning_data.star
```

#### Extraction in Warp
We can now use the generated `.star` file to extract subtomograms in Warp. To start the extraction, make sure Warp is in `*.tomostar` mode, then click on the `Reconstruct sub-tomograms` button at the top of the screen in the `Overview` tab. A dialog will open: fill in the settings as follows:

- ???

When ready, click on `???`. To prepare the directory structure for relion, we will choose to put the output `.star` file inside a new `root/relion` folder and call it `subtomograms_5Apx.star`.

![extract subtomograms](https://i.ibb.co/KKMwDqJ/subtomo-extraction.png)

We extract in a box twice as large because we have halved the pixel spacing.


### 3D auto-refine in RELION

We can now perform a gold standard automatic refinement of the whole dataset at 5$\AA/px$ in RELION. Moving to RELION at this stage simplifies the workflow as Warp and M were designed to work directly with RELION.

> By default, Dynamo uses a binary wedge model to account for the sampling of information in Fourier space for each subtomogram. Warps CTF volumes are designed for use with RELION and should yield more accurate weighting of Fourier coefficients during reconstruction. A small summary of the authors opinions on the advantages and limitations of alignment procedures in each software package is provided as an appendix to this guide.

Before alignment, we need to create an initial template map. We first select a random subset of particles with simple bash commands:
```bash
# keep the header
head subtomograms_5Apx.star -n 30 > random_subset_5Apx.star
# use 500 random particles
tail subtomograms_5Apx.star -n +31 | shuf -n 500 >> random_subset_5Apx.star
```

Then, we use *relion_reconstruct* from the command line to average them. We need to make sure to appropriately weight the reconstruction according to the CTF volumes and tell the program that we are working with 3D images.
```bash
relion_reconstruct --i random_subset_5Apx.star --o random_subset_5Apx.mrc --3d_rot --ctf
```

> This step also serves as a useful sanity check. The resulting reconstruction should look like the hexagonal lattice we have seen previously. If it doesn't, something went wrong, check your parameters carefully for each step.

#### Alignment parameters

To start the project, run *relion* from the `relion` directory.
```bash
relion
```

We then set up a 3D auto-refine job with the following parameters

![relion 1](https://i.ibb.co/Vm8yS3Y/relion-1.png)

We could use a mask at this stage, this can be useful when trying to optimise refinement of a subregion (such as the central hexamer). We will refine without a mask for now as this refinement serves only to make sure that the particles remain well centered and we expect to go significantly beyond 10A.
![relion 2](https://i.ibb.co/FHMQ5Y5/relion-2.png)

We use a conservative initial lowpass of 30A to avoid overfitting

![relion 3](https://i.ibb.co/TW7FpqY/relion-3.png)

![relion 4](https://i.ibb.co/PTQvLf3/relion-4.png)

We use a particle diameter here covering the whole box to continue making use of the signal from neighbouring hexamers to drive alignment, we will change this once we start aiming for more optimal refinements focussed on teh central hexamer.

![relion 5](https://i.ibb.co/tz5QxZG/relion-5.png)

![relion 6](https://i.ibb.co/8D9Rw1D/relion-6.png)

![relion 7](https://i.ibb.co/M8WBk0X/relion-7.png)

The specific computational parameters will depend upon the configuration of your computing resources. Here, we are running on a computer with 

- 4 x GeForce GTX 1080 TI GPUs 
- 16 x E5-2620 v4 2.10GHz CPUs (2 threads per core)
- 256GB RAM

Once ready, click on `Run!` to start processing. This will take several hours.

### Subtomogram extraction at 1.6$\AA/px$

Once the alignment at 5$\AA/px$ is done, we can repeat the procedure at a smaller pixel size allowing us to obtain a higher resolution reconstruction. We use Warp to reextract sutomograms at 1.6$\AA/px$ using the `*_data.star` from the refinement at 5$\AA/px$ then rerun the alignments in Relion.

First, we need to reformat the output `.star` file from the Relion3.1 specification (currently not supported by Warp) to Relion3.0, using a command provided by `dynamo2m`. To do so, navigate to `relion/Refine3D/refine_5apx` and identify the last iteration number (for us, it was `it_023`) and run:
```bash
relion_star_downgrade -s run_it023_data.star
```

From the new file, we can now extract subtomograms from Warp, similarly to how we did last time. This time, the input coordinates use 5$\AA/px$ and the output should be scaled to 1.6$\AA/px$.

Since now we want to be able to refine the central particle to high resolution, we should reduce the relative box size: this will prevent the small differences between neighbours to affect the alignment of the central particle. A box size of 128$px$ is a bit smaller relatively to the previous one, while still big enough for our particle.

> If possible, it is better to keep the box size to powers of 2, to maximise computational efficiency.

Save the file in the `relion` directory as `subtomograms_1.6Apx.star`

![extract subtomograms 1.6](https://i.ibb.co/s9jN57s/subtomo-extraction-1-6.png)

### Refinement Mask

- better focus for refinement
- must be soft edged to avoid FSC artifacts


```matlab
dpkdev.legacy.dynamo_mapview()
```

- dynamo low pass filter, central cylinder of 160A
    - band 0-10. layer to see, apply, save (as mrc!)

```bash
relion_mask_create --i mask_1.6Apx_raw.mrc --angpix 1.6 --extend_inimask 5 --width_soft_edge 10 --o mask_1.6Apx.mrc
relion_image_handler --i mask_1.6Apx.mrc --sym C6 --o mask_1.6Apx_c6.mrc
```

### Refinement at 1.6$\AA/px$


## Next step
* [Multi particle refinement in M](m.md)
