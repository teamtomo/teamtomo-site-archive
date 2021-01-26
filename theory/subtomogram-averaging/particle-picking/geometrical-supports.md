# Using a supporting geometry
In cryo-ET, objects of interest are often bound to or part of a larger supporting object such as a membrane, a vesicle or a filament. 
When this is the case, they often exhibit specific spatial relationships to the support.

This information, the position and orientation of particles relative to a supporting geometry, is often useful in subtomogram averaging experiments.

## The process
The general process for making use of this spatial information is simple

1. Generate a 3D model of the supporting geometry from tomogram annotations
2. Seed particle positions and orientations relative to the supporting geometry

## Advantages
Providing accurate initial estimates for the positions and orientations of particles at the start of a subtomogram averaging experiment allows you to
- limit angular searches appropriately
- restrict shifts appropriately

Constraining these parameters ensures that particles do not 'drift' during iterative refinement procedures and get trapped in a local minimum, a common phenomenon when working with low SNR cryo-ET data.

A reduced search space also alleviates some of the computational burden of performing global searches.

## Disadvantages 
Generation of these 3D models is usually semi-automated at best, as opposed to [template matching](template-matching) which is fully automated. This can mean it takes significantly longer for large datasets.