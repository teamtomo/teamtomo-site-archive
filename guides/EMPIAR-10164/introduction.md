# EMPIAR-10164 (HIV VLPs)

## Introduction

In this tutorial, we will reprocess a five tilt-series subset of 
[*EMPIAR-10164*](https://www.ebi.ac.uk/pdbe/emdb/empiar/entry/10164/) *ab initio*, without using an external reference.

```{note}
This subset was used to benchmark both 
[NovaCTF](https://www.sciencedirect.com/science/article/pii/S1047847717301272)
and 
[Warp](https://www.nature.com/articles/s41592-019-0580-y).
```


This processing will be carried out within the framework described [here](link to preprint).

From these five tilt-series this procedure can produce a 3.4$\AA$ reconstruction 
of the HIV-1 CA-SP1 hexamer.

### A note about scripting
As the software ecosystem for cryo-ET matures, some scripting is often required to achieve your goals. 
This tutorial is provided with all necessary [scripts](../../../../scripts).

For illustrative purposes, the contents of these scripts will appear as `code blocks` in the tutorial when used. 

```matlab
% this is a comment
disp('Hello World!')
```

Reading these blocks is intended to serve as a gentle introduction to MATLAB scripting for working with
the powerful tools Dynamo has to offer. 

For general purpose scripting, we personally prefer `Python` for its wealth of open source
[data science infrastructure](https://www.scipy.org/) 
and 
[educational resources](https://www.youtube.com/watch?v=5rNu16O3YNE&t=4103s).

### Requirements and Setup

#### Hardware

1. A reasonably modern CPU. We used ...
%% cpu brand and model, number of cores
2. At least 32 GB random-access memory (RAM) to extract particle at 2.5 A/px. In order to extract at 1.7 A/px, we used a computer with 128 GB of RAM.
%% correct? can we test if possible with 64? Also, fix angstrom symbol in latex.
3. At least 1 NVIDIA graphics processing unit (GPU), with at least ? GB of dedicated memory. We used a computer with 2 NVIDIA Titan ?, each with ? GB of dedicated memory.
%% which gpu? how much memory did we really need?
4. At least ?GB of free disk space. To keep the read/write times low, we recommend to use a Solid State Drive (SSD).
%% how big is the dataset, and how much room does the processed data take?


#### Software

- Access to both Windows and Linux operative systems
- MATLAB r2019a or later (with ??? tools, explain adding path)
- Warp 1.0.9 or later
- Relion 3.0.8 or later
- Dynamo 1.1.478 or later
- `dynamo2m`
- `autoalign_dynamo`
- scripts provided with this guide

#### Downloading the data
The five tilt series subset of EMPIAR-10164 used for this guide should first be downloaded from 
[EMPIAR](https://www.ebi.ac.uk/pdbe/emdb/empiar/entry/10164/). 

For this purpose, we provide a simple shell script 
([`download.sh`](../../../../scripts/download.sh)) together with this tutorial.

```bash
echo "Downloading the raw data. This may take a couple of hours!"
echo
echo
for i in 01 03 43 45 54;
do
    echo "===================================================="
    echo "================= Downloading TS_${i} ================"
    wget --show-progress -m -q -nd -P ./mdoc ftp://ftp.ebi.ac.uk/empiar/world_availability/10164/data/mdoc-files/TS_${i}.mrc.mdoc;
    wget --show-progress -m -q -nd -P ./frames ftp://ftp.ebi.ac.uk/empiar/world_availability/10164/data/frames/TS_${i}_*.mrc;
done

```

`download.sh` organises files according to the directory structure expected by the rest of the guide.

```bash
.
├── frames
│   ├── TS_01_000_0.0.mrc
│   ├── TS_01_001_3.0.mrc
│   └── ...
└── mdoc
    ├── TS_01.mrc.mdoc
    ├── TS_02.mrc.mdoc
    └── ...
```

Files with the `.mrc` extension are multi-frame micrographs for each tilt angle in a tilt series. 
They are in the [MRC2014](https://www.ccpem.ac.uk/mrc_format/mrc2014.php) file format.

Files with the `.mdoc` extension are [SerialEM](https://bio3d.colorado.edu/SerialEM/) metadata files.

**Downloading the data may take a few hours. Start this early!**

### Documentation links
If you are looking for a more in-depth explanation of a parameter, setting or tool, you are encouraged to check out the documentation of any software packages we used.

- **Warp**: [Warp user guide](http://www.warpem.com/warp/?page_id=51)
- **Dynamo**: [Dynamo wiki](https://www.wiki.dynamo.biozentrum.unibas.ch/w/index.php/)
- **Relion**: [RELION wiki](https://www3.mrc-lmb.cam.ac.uk/relion/index.php/Main_Page)


### Next step
Once the data is downloaded, click [here](preprocessing.md) to move on to preprocessing!

