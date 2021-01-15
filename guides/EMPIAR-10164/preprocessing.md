# Preprocessing

In this chapter, we will detail the necessary steps to take you from multi-frame micrographs to tomograms. 

The main steps in this chapter are:
1. **Micrograph Preprocessing**
   
   Process multi-frame micrographs and generate tilt series stacks
   
2. **Tilt-Series Alignment**
   
   Estimate the image transformations required for tomogram reconstruction
   
3. **Tilt-Series CTF Estimation and Tomogram Reconstruction**
   
   Reconstruction of 3D-CTF corrected downsampled tomograms and deconvolved volumes for visualisation


## Micrograph Preprocessing

We are going to use Warp for some initial image processing. 

In this section:
1. Initial estimates for defocus and inter-frame motion will be obtained.
2. Multi-frame micrographs will be merged into single images based on estimated motion.
3. Gold fiducials will be detected for masking during tomogram reconstruction.

### Import and binning

To import new data into Warp, click on the path next to `Input` and select the `frames` directory. For the HIV-5-TS data, make sure that the selected format is `*.mrc`.

We need to correctly set the pixel size to match that of the raw data; in this case, 0.6750 $Å/px$. 

For HIV-5-TS, the data were collected in super resolution mode, the physical pixel size is 1.35 $Å/px$. Processing data without first downsampling may reduce the aliasing of high-frequency signals in the image but significantly increases the computational overhead. In this case we will use Warp to downsample the data by a factor of 2, in order to return to the physical pixel size of the detector.

> With a binning factor of *n*, the frames will be Fourier-cropped to $size/2^n$.

![binning](https://i.ibb.co/tMdFXQb/binning.png)

### Gain correction

The EMPIAR entry for EMPIAR-10164 indicates that the images were already gain corrected. We can skip gain correction by leaving this section unchecked.

```{note}
When processing other data, you may need to provide a gain reference here. 
Make sure that the orientation of the reference and the images correspond!
```

### CTF estimation

Accurate estimation of Contrast Transfer Function (CTF) parameters is essential for obtaining high resolution reconstructions.

```{note}
The CTF estimation performed at this stage is only used for tilt handedness evaluation; 
we'll explain this in more detail later.
```

Parameters in **bold** are those we used for processing this dataset.

The following parameters depend entirely on the microscope setup used for data collection, for HIV-5-TS:
- `Voltage`: **300** kV.
  
    The acceleration voltage used in the electron microscope
- `Cs`:  **2.70** mm.
  
    The spherical aberration of the electron microscope
- `Phase Shift`: **No**.
  
    Whether to model a phase shift in the CTF, usually only used for data collected with a phase plate.

The remaining parameters should be set depending on the dataset:
- `Defocus`: **0.5 to 5** µm
  
    The upper and lower limits for defocus estimation. When a dataset is expected to have higher or lower defoci, this range should be expanded.
- `Use Movie Sum`: **Yes**
  
    Whether to use the movie sum for CTF parameter estimation. Activating this should lead to slightly better results for low-dose images. 
- `Amplitude`: **0.07**
  
    The percentage of amplitude contrast for the CTF model. For cryo-EM typical values are 0.07-0.10.

Some computational parameters can also be adjusted:

- `Window`: **512** 
  
    The size of power spectra used for CTF estimation
- `Range`: **40.0-5.0** Å
  
    The range of spatial frequencies to use for fitting. At low frequencies, data often doesn't match the CTF model. At high frequencies there is often not enough signal for accurate CTF estimation. In our experience, 40.0-5.0 is usually a good range for high magnification tilt-series images (1-3  $Å/px$) with ca. 3 $e^-/Å^2/tilt$ image.

![ctf parameters](https://i.ibb.co/Hpn7Lft/ctf.png)

### Motion estimation

In order to compensate for both mechanical stage-drift and beam-induced sample motion, 
we estimate and correct for the inter-frame motion present in the image. 
In this case, we leave the motion correction parameters as defaults.

![motion corr](https://i.ibb.co/Pgxsjt5/motion.png)

### CTF and Motion Model Resolution

Warp allows us to estimate how CTF and inter-frame translational motion parameters change in both space and time.

The resolution of this spatiotemporal model (x, y, t) can be set in the **Models** panel: the first two values represent the spatial resolution of the model in *x* and *y* , while the third value sets the temporal resolution (at most, the number of frames in a multi-frame micrograph). 

For tilt-series data, a CTF model resolution of 2x2x1 is usually sufficient to observe how defocus changes across the image, which is required to determine the 'tilt-handedness' of the data. More accurate defocus values will be estimated in the tilt-series CTF estimation procedure prior to tomogram reconstruction.

A motion model of 1x1xn where n is the number of frames typically ensures that accurate estimates can be obtained from low-dose data. The alignment of individual frames can be improved once a high SNR reference has been obtained, this is performed in the multi-particle refinement step of the workflow.

For HIV-5-TS, EMPIAR indicates that we have 8 frames per image, so we set the resolution of the motion model to 1x1x8

![CTF and motion model](https://i.ibb.co/6mwzZKb/models.png)

### Bead Masking

While gold fiducials are useful for the accurate alignment of tilt series, their high contrast will have negative effects on the final tomographic reconstruction. For this reason, we use Warp to mask out any beads prior to tomographic reconstruction.

The `Pick Particles` panel gives access to `BoxNet`, a deep convolutional neural network designed to pick particles and mask out unwanted subregions in single-particle cryo-EM. 

```{note}
A version of BoxNet we retrained for to mask gold fiducials is [provided](TODO:add-link) with this tutorial. 
In order to access it from Warp, the `BoxNet2MaskBeads_20200607` ???better name??? directory must be placed in the Warp installation folder under the `boxnet2models` directory.

```

To select the pretrained model in Warp, click on the currently selected BoxNet model and select the `BoxNet2MaskBeads_20200607` model. 

As we are only using this model for particle picking, the parameters relating to particle picking can be safely ignored.

```{sidebar}
The provided version of BoxNet was retrained on 3 tilt series from a high magnification dataset (1.7 $Å/px$) containing 10 $nm$ gold beads. We have succesfully used it on a variety of datasets, but there is no guaranteee it will work on yours. To learn more about retraining BoxNet, [see this page](http://www.multiparticle.com/warp/?page_id=137).
```

![boxnet](https://i.ibb.co/5BvkK9x/masking.png)

### Output Parameters

In the `Output` panel, we can choose not to include frames at the beginning and end of a movie. The first frames from a multi-frame micrograph of a given exposure often display increased translational motion. In this case, we chose to include all frames from the micrograph to maximise the signal present in the final images. 

By selecting `Average`, we ensure the output of one 2D image per multi-frame micrograph in which the inter-frame motion has been corrected according to the motion model

`Odd/even` frame averages can be generated to facilitate Noise2Noise based denoising, this is not covered in this guide but we recommend playing with it.

`Aligned stack`s of frames can also be generated; this can be useful in single-particle analysis of frame series data to enable the use of RELION's Bayesian polishing. In our case, we leave it blank.

### Start Processing!

We are now ready to press **START PROCESSING**.

If setup as described this will
- Estimate CTF and inter-frame motion parameters according to the spatiotemporal model
- Generate one micrograph per tilt in which the motion has been corrected according to the motion model
- Generate masks around gold fiducials in each image using the provided BoxNet model

![processing](https://i.ibb.co/9nPKyLy/process.png)

#### Monitoring the results
During processing, you can check the results by switching to the `Real Space` and `Fourier Space` tabs at the top of the Warp interface. Explore these sections, checking that the CTF model matches the experimental curve, the defocus estimates appear to change as expected with tilt angle and that beads masks seem appropriate.

TODO: add some examples of good and bad CTF fits, good bead masks etc


### Tilt-Series Stack Generation
Images in each tilt-series must be assembled into a stack.

```{note}
These data were collected with a {doc}`dose-symmetric tilt scheme<../../general-principles/data-collection/tilt-schemes>`
Images should be stacked sequentially according to their tilt angle for visualisation. 
```

#### Deselect bad images

Before we generate tilt series stacks from our aligned 2D images, we should discard any bad images in our dataset. To do so, switch to the `Real Space` tab at the top and manually inspect all the tilt images. To quickly check the images, hover your mouse over the selection bar at the bottom of the screen and move it along its length to inspect the thumbnails. To inspect an image in more detail, click on the bar and the image will be enlarged.

If an image is heavily contaminated, black, blurred, a grid bar blocks a significant part of it or you otherwise deem it unsuitable, deselect the image by clicking the checkbox next to its name. The bar should turn grey once an image is deselected.

> With larger datasets, quickly scanning images in this way can be inconvenient. To make this a bit easier, use the search bar to display only a subset of the dataset (For HIV-5-TS we could search `TS_01`, `TS_02`...).

For this dataset we only have to discard two bad images: `TS_01_039` and `TS_03_039`.

![deselect bad image](https://i.ibb.co/nQsc77B/bad-image.png)

### Stack generation in `Warp`

Before aligning the tilt series in `Dynamo`, we need to export each tilt-series as an image stack. 

To do this, we first have to put Warp into `tomostar` mode. 
We do this by clicking on the `*.mrc` extension on the top left, and selecting `*.tomostar`. 

To generate the tilt-series stacks, click on the `import tilt series from IMOD` button at the top of the screen. 
In the newly opened window, we should now select the 
`Folder with original movies` and the `Folder with .mdoc files`. 
In this case, they are the `frames` and `mdoc` folders, respectively.

```{note}
We don't need to set the pixel size and electron dose per tilt just yet: we will set them later when importing the aligned tilt series back into Warp. 
We also don't need to worry about inverting tilt angles at this stage, tilt handedness will be checked (and eventually corrected for) at a later step.
```

Click on `Create stacks for IMOD` to start exporting the data. We can immediately move on to the next step without having to wait for the stack generation to finish, thanks to `autoalign_dynamo`'s on-the-fly processing.

![create stack](https://i.ibb.co/YLp32wg/create-stack.png)

## Tilt-series alignment

### Overview
In this section, we will use the `autoalign_dynamo` package, which leverages Dynamo's automated tilt series alignment workflows.

This program aligns tilt-series in `Dynamo` and prepares all necessary metadata for import back into `Warp`.

A basic overview of the tilt-series alignment procedure in Dynamo is:
- Estimation of the putative positions of fiducials in all the images by cross-correlation (CC) against a synthetic template.
- Rejection of features that are not rotationally symmetric, and therefore likely not beads.
- Indexing of bead observations, attempting to determine which beads correspond to the same underlying object in 3D.
- Iterative refinement of the alignment parameters and bead positions. 
- Reintegration of missing observations based on an updated projection model.
- Removal of observations with large residuals.

This procedure explicitly attempts to maximise the number of observations which should increase the global accuracy of the final solution.

```{note}
For a detailed, step-by-step explanation of the procedure, 
check out the 
[Walkthrough on GUI based tilt series alignment](https://www.wiki.dynamo.biozentrum.unibas.ch/w/index.php/Walkthrough_on_GUI_based_tilt_series_alignment) 
on the Dynamo wiki.
```

To enable use of these workflows within the Warp preprocessing pipeline we provide a package `autoalign_dynamo`. `dautoalign4warp` is a function provided by this package which handles running the Dynamo alignment workflow on all tilt-series and prepares all metadata for import back into Warp. This procedure can be run on-the-fly, starting as soon as the first tilt-series has been generated by Warp.

### Aligning the tilt-series
Open MATLAB, make sure that [dynamo and autoalign_dynamo are activated](https://github.com/alisterburt/autoalign_dynamo#activation-and-running) and navigate to the `frames` directory

The command we need to use is: 
```matlab
dautoalign4warp(<warp_tilt_series_directory>, <pixel_size_angstrom>, <fiducial_diameter_nm>, <nominal_rotation_angle>, <output_folder>)
```
Warp puts the generated tilt series in a new `imod` directory, one level below the `frames` directory.

For this dataset the fiducial diameter is 10 nm and the nominal rotation angle is 85.3 degrees.

We can start aligning tilt-series with the following command:
```matlab
dautoalign4warp('./imod', 1.35, 10, 85.3, './dynamo_alignments')
```
```{sidebar}
The nominal rotation angle is the angle of the tilt axis relative to the Y axis in the tilt-series (counter-clockwise positive).  
It can usually be found in the mdoc file for a tilt series, under `Tilt axis angle`. 
If you don't know, ask your microscope manager!
```

This command will generate the transforms needed to align a tilt series

Once running, `autoalign_dynamo` will keep processing incoming data from Warp and generate the metadata necessary for tomogram reconstruction. 
As soon as the alignments are done, we can start CTF estimation on the tilt-series and reconstructing tomograms.

#### Checking the results

% add some details for checking the results, how to open the tomogram and the .mod file together in 3dmod and checking that the beads were tracked properly 


## Tilt-Series CTF Estimation and Tomogram reconstruction

Up to now we have:
- preprocessed the 2D images
- generated and aligned tilt-series

We will now estimate the CTF parameters for each tilt-series, 
check that our CTF model has the correct handedness and reconstruct the tomograms.

### Import aligned tilt-series

To import the newly aligned tilt series back into Warp, click the `import tilt series from IMOD` button and select the `frames` and `mdoc` folders as before. Then, set `Root folder with IMOD processing results` to the new `dynamo_alignments` directory.

The checkboxes should now appear checked in the `Aligned` column on the right hand side of the import window.

Differently from earlier, now we also need to enter the pixel size of the tilt-series and the electron dose that the sample was exposed to per tilt. 

For this dataset this is the binned pixel size of 1.35 Å/px, 
and according the the EMPIAR entry the dose is roughly 3 e^-/Å^2\s per tilt.

![import alignment](https://i.ibb.co/Jrr8K69/import-dynamo.png)

### Tilt-Series CTF estimation

In this step, Warp will reestimate the CTF parameters for each tilt series according to a 3D model of the underlying signal which accounts for defocus variations due to tilt angle, sample thickness and sample inclination relative to the imaging plane. Using this 3D model, individual particles can be reconstructed from images which have been CTF corrected according to their exact position within the reconstructed volume.

#### Check tilt handedness

The tilt handedness check allows us to check that defocus varies across each image as expected by Warp's CTF model for each tilt-series.

To perform the check, we first estimate the CTF for one tilt-series by hitting `estimate for just this tilt-series` in the `Fourier Space` tab. Once this has completed, we have to hit `Check tilt handedness`. If Warp sees that the defocus estimates don't match what it expects in terms of how the defocus changes with tilt-angle, it will offer the option to flip the defocus handedness of the CTF model for each loaded tilt-series. If the correlation found is not convincing, try other tilt-series in the dataset.

Once we are sure about the tilt handedness, we can proceed with the tilt-series CTF estimation procedure.

#### CTF estimation

The settings for tilt-series CTF estimation should be the same as those used earlier when estimating CTF parameters for 2D micrographs. In this case, we do not control the spatiotemporal resolution of the CTF model.

### Reconstruct tomograms

We now have everything we need to reconstruct our tomograms. In Warp, we don't need to reconstruct whole tomograms at this step. Instead, downsampled tomograms can be generated for initial particle picking and volumes centered on each object of interest can be reconstructed later at the desired pixel size. This reduces the computational burden of generating and extracting particles from large, unbinned tomograms which can easily be over 100GB in size. 

We have to define the reconstruction area by setting the `Unbinned tomogram dimensions`. These are the dimensions that the tomogram would have if reconstructed at the pixel size of the tilt-series. To capture the full extent of the imaged area, we should use 4000 x 4000 for the x and y dimensions (because we downsampled our original ~8000x8000 super-resolution pixels by a factor of two). In z, we want the reconstruction to be large enough to include the entire imaged sample. In this case, 3000px is more than enough.

![reconstruction size](https://i.ibb.co/jHwXktH/reconstruction-size.png)

We can then click on `reconstruct full tomograms` at the top of the `Overview` tab to open the reconstruction dialog box.

Working at smaller pixel sizes initially significantly increases your ability to quickly test new ideas at the expense of the loss of high-resolution information. Generally, we aim for a pixel size which allows our object of interest to fit comfortably in a 32px^3 box. If we don't know the size of our object of interest 10-15  $Å/px$ is usually a good starting point. For HIV-5-TS, we generate tomograms at 10 $Å/px$.

We invert contrast such that any averages of particles in the tomograms will be light-on-dark. Whilst not strictly necessary, this is a convention which facilitates visualisation in programs such as ChimeraX and the use of certain image processing tools which expect this inverted contrast.

We also select `Also produce deconvolved version`; this generates a tomogram which has been filtered for visualisation alongside the unfiltered reconstruction suitable for subtomogram averaging.

Leave `Reconstruct half-maps for denoising` and `Keep only fully covered voxels` unchecked for now, the first is useful if you want to denoise your data and the second will leave zeros in the regions not contributed to by all images in the tilt-series.

Warp may have marked some tilt series as filtered out. Since we are not making active use of filters in this tutorial, this is not a problem. Simply select `Include items outside of filter ranges`. To learn more about the Warp filters, check out the [Warp tutorial on frame series](http://www.warpem.com/warp/?page_id=185).

Once ready, click on `Reconstruct` to reconstruct the tomograms.

![reconstruction parameters](https://i.ibb.co/QY5X9hc/reconstruction-settings.png)



## Next step
click [here](picking.md)
