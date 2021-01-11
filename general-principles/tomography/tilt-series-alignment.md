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

