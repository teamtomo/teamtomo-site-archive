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
