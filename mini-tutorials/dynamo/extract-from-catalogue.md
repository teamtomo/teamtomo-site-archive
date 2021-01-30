# Extracting particles

This mini-tutorial will explain how to extract a set of particles from multiple tomograms in a `Dynamo` catalogue.

## Prerequisites
- a `Dynamo` catalogue containing your tomograms
- [models](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Model) for the particles you wish to extract saved in the catalogue

If you have been picking your particles/supporting geometries in `dtmslice`, opened from the catalogue manager (`dcm`) then you're ready to go!


## The procedure

Open your catalogue in `dcm` and click through the tabs below to see the whole procedure

```{tabbed} select tomograms
Select the tomograms you would like to crop from (or use the select all button)
![select volumes](extract-from-catalogue.assets/select-all-volumes.gif)
```

```{tabbed} open volume list manager
The volume list manager can create volume list (`.vll`) files containing the information needed for cropping particles.

Open the volume list manager from the `Crop particles` menu at the top of the `dcm` window.

![open volume list manager](extract-from-catalogue.assets/open-volume-list-manager.gif)
```

```{tabbed} create volume list file
Create a volume list (`.vll`) file by 
- picking the models from which you want to crop in the GUI 
- hitting the `create list` button.
   
![create volume list file](extract-from-catalogue.assets/create-volume-list.gif)
```

``````{tabbed} extract particles

````{margin}
```{note} Dynamo data folder
A Dynamo data folder contains
- Subvolumes for each particle
- Alignment metadata for each particle (`crop.tbl`)
- A [tomogram-table map file](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Tomogram-table_map_file) (`indices_column20.doc`)
```
````
In the particle extraction GUI which pops up
- set the particle sidelength to your desired box size
- hit `crop particles`. 

This will generate a `Dynamo` format data folder in the current directory with the name in the `data` box.

![particle extraction](extract-from-catalogue.assets/crop-particles.gif)

```{attention}
We use the *data folder in dBoxes...* option here to avoid problems with having thousands of files in the same directory.
Read more [here](https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Generic_data_containers).
```

---
Once complete, you will have a `Dynamo` format data folder containing your particles, you're ready for refinements!
