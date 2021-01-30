# Download the data
The five tilt series subset of EMPIAR-10164 used for this guide should first be downloaded from 
[EMPIAR](https://www.ebi.ac.uk/pdbe/emdb/empiar/entry/10164/).

For this purpose, we provide a simple shell script 
([`download.sh`](https://github.com/teamtomo/teamtomo.github.io/blob/master/walkthroughs/EMPIAR-10164/scripts/download.sh)).

```{note}
Downloading the data may take a few hours. Start this early!
```

`download.sh` organises files according to the directory structure expected by the rest of the guide.

````{tabbed} shell script
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
````

````{tabbed} directory structure
```{code block} bash
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
````

````{tabbed} file extensions
Files with the `.mrc` extension are multi-frame micrographs for each tilt angle in a tilt series. 

They are in the [MRC2014](https://www.ccpem.ac.uk/mrc_format/mrc2014.php) file format.

Files with the `.mdoc` extension are [SerialEM](https://bio3d.colorado.edu/SerialEM/) metadata files, we have one per tilt-series.

They are plain text files containing metadata about images in a tilt-series.
````
