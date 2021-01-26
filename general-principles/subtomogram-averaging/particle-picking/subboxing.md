# Subboxing

Subboxing means deriving new particle positions and orientations from an existing set of positions and orientations.

The generated positions are usually centered on a region of interest within an existing reconstruction.

This process is useful for
- simple recentering of particles
- focussing on individual subunits in a complex

A typical use case is shown for the lattice structure of 
[*EMD-10160*](https://www.ebi.ac.uk/pdbe/entry/emdb/EMD-10160) in the image below. 

![subboxing example](subboxing.assets/subboxing.png)

In this image, each white density is a receptor dimer in a chemosensory array. 

Arrays form of receptor trimer-of-dimers, the little triangles of three white dots. The blue particles are centered in the middle of hexagons of these trimer-of-dimers.

Subboxing has been used to derive the orange particle positions and orientations from the blue set of particles.

