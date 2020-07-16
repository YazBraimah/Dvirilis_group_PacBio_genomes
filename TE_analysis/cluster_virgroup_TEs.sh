#!/bin/bash -l
#SBATCH --job-name=cluster_virgroup_TEs
#SBATCH --output=cluster_virgroup_TEs.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=4000
#SBATCH --time=04:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02

# sbatch cluster_virgroup_TEs.sh

# date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage ## Mount data server
/programs/bin/labutils/mount_server cbsubscb14 /storage

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# copy in the libraries
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/Dvir_TElib.DINEsatmod.fa .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dnov/Dnov_TElib.DINEsatmod.fa .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/Dame_TElib.DINEsatmod.fa .

# rename the sequences so we can identify the species.
cat Dvir_TElib.DINEsatmod.fa | sed 's/family/Dvir/g' > Dvir_TElib.renamed.fa
cat Dnov_TElib.DINEsatmod.fa | sed 's/family/Dnov/g' > Dnov_TElib.renamed.fa
cat Dame_TElib.DINEsatmod.fa | sed 's/family/Dame/g' > Dame_TElib.renamed.fa

# now get only the non-RC and other sequences, because that will be a mess

cat Dvir_TElib.renamed.fa | grep '^>' | cut -f 2 -d '>' | grep -v "Helitron" | grep -v "DINE" | grep -v "Other" > Dvir_TEs.txt
cat Dnov_TElib.renamed.fa | grep '^>' | cut -f 2 -d '>' | grep -v "Helitron" | grep -v "DINE" | grep -v "Other" > Dnov_TEs.txt
cat Dame_TElib.renamed.fa | grep '^>' | cut -f 2 -d '>' | grep -v "Helitron" | grep -v "DINE" | grep -v "Other" > Dame_TEs.txt

# get the select sequences from the fasta files
xargs samtools faidx Dvir_TElib.renamed.fa < Dvir_TEs.txt > Dvir_TElib.nosat.fa 
xargs samtools faidx Dnov_TElib.renamed.fa < Dnov_TEs.txt > Dnov_TElib.nosat.fa 
xargs samtools faidx Dame_TElib.renamed.fa < Dame_TEs.txt > Dame_TElib.nosat.fa 

# now combine these files and cluster with CDhit

cat *_TElib.nosat.fa > virgroup_TElib.nosat.fa

/programs/cd-hit-v4.6.1-2012-08-27/cd-hit-est -aS 0.8 -c 0.8 -g 1 -G 0 -A 80 -M 10000 -i virgroup_TElib.nosat.fa -o virgroup_TE_clusters.fa -T 1

# copy out the output
cp virgroup_TE_clusters.* /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering


cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)