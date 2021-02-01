# Subtomogram averaging

The whole process of subtomogram averaging can be broadly divided into three blocks.

1. `preprocessing` 
2. `particle-picking`
3. `refinement` 

The `preprocessing` block transforms experimental 2D micrographs into 3D reconstructions of an imaged region. The `particle-picking` block generates putative positions and orientations for objects of interest within each volume as well as initial reference(s) for subsequent refinement. The `refinement` block is concerned with the optimisation of reconstruction(s) from imaging data associated with each particle position. 

```{image} index.assets/subtomo-overview.png
:scale: 25%
:align: center
```

Each of these 'blocks' is a world unto itself, and this abstraction is a gross oversimplification. Check the sidebar for more details!