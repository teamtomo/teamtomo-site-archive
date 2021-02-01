# Tilt-series alignment

For accurate 3D reconstruction, a set of images should represent a fixed body rotating around a fixed axis.

Due to both mechanical stage drift and beam-induced sample motion during data collection, this is not the case 
for experimental cryo-ET data.

The goal of tilt-series alignment is to determine the transformations which should be applied to images for 
accurate 3D reconstruction.

```{note}
From the [IMOD Tomography Guide](https://bio3d.colorado.edu/imod/doc/tomoguide.html#FINAL%20ALIGNMENT)
"In order to transform the images, one needs to determine the 
rotation, translation, and scaling (magnification) to be applied to each image. 
It is also possible to solve for variables which will correct for linear distortions of the specimen."
```

## Fiducial based
Exogenous fiducial markers, usually 10 nm gold nanoparticles coated with a protein to prevent aggregation, are usually added to cryo-ET samples.

Small, round and highly contrasted in even low-dose electron micrographs, these gold beads are detected, tracked and fit to a projection model.
The projection model can be used to derive a set of transformations which align the projection images, a procedure which has some limitations.

A detailed treatment of this topic, written by David Mastronarde, can be found [here](https://doi.org/10.1007/978-0-387-69008-7_6).


## Fiducialless
In some cases, using fiducial markers to align tilt-series is impossible. For example, FIB-milling is incompatible with gold nanoparticle fiducial markers as they tend to end up at the air-water interface during vitrification and are subsequently removed during sample milling.

In these cases, alternative methods must be used which make use of the biological material in each image for alignment.

Fiducialless alignment is challenging, in part because the underlying signal is not the same for different images in a tilt-series, 
it represents a projection of the same 3D object from a different angle.
