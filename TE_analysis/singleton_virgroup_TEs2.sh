#!/bin/bash -l
#SBATCH --job-name=singleton_virgroup_TEs2
#SBATCH --output=singleton_virgroup_TEs2.o%j
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


#/programs/bin/labutils/mount_server cbsufsrv5 /data1
#/programs/bin/labutils/mount_server cbsuclarkfs1 /storage ## Mount data server
/programs/bin/labutils/mount_server cbsubscb14 /storage

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

# get the singletons for each species and the blast results.
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/*singletons.fa .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/*blastout .

# for virilis, get the list of total singleton sequences

samtools faidx Dvir.singletons.fa
cat Dvir.singletons.fa.fai | awk '$2>=100 {print $1}' | sort -u > Dvir.all.singletons

# vir, get the sequences that are present in the Dnov genome
cat Dvir.singletons_Dnov.genome.blastout | awk '{if($3>=80 && $4>=100) {print $0}}' | cut -f 2 | sort -u > Dvir.matches_Dnov.genome

comm -23 Dvir.all.singletons Dvir.matches_Dnov.genome > Dvir.notpresent_Dnov.genome

# vir, get the sequences that are present in the Dame genome
cat Dvir.singletons_Dame.genome.blastout | awk '{if($3>=80 && $4>=100) {print $0}}' | cut -f 2 | sort -u > Dvir.matches_Dame.genome

comm -23 Dvir.all.singletons Dvir.matches_Dame.genome > Dvir.notpresent_Dame.genome

# now get the virilis sequences that don't cluster with another and are not present in either amer or nov. 

cat  Dvir.matches_Dnov.genome  Dvir.matches_Dame.genome | sort -u > Dvir.matches_Dnov_Dame.genome
comm -23 Dvir.all.singletons Dvir.matches_Dnov_Dame.genome > Dvir.true.singletons


#### now for novamexicana  #####
samtools faidx Dnov.singletons.fa
cat Dnov.singletons.fa.fai | awk '$2>=100 {print $1}' | sort -u > Dnov.all.singletons

# get the sequences that are present in the vir genome

cat Dnov.singletons_Dvir.genome.blastout | awk '{if($3>=80 && $4>=100) {print $0}}' | cut -f 2 | sort -u > Dnov.matches_Dvir.genome

comm -23 Dnov.all.singletons Dnov.matches_Dvir.genome > Dnov.notpresent_Dvir.genome

# get the sequences that are present in the Dame genome
cat Dnov.singletons_Dame.genome.blastout | awk '{if($3>=80 && $4>=100) {print $0}}' | cut -f 2 | sort -u > Dnov.matches_Dame.genome

comm -23 Dnov.all.singletons Dnov.matches_Dame.genome > Dnov.notpresent_Dame.genome

# now get the nov sequences that don't cluster with another and are not present in either amer or vir. 

cat Dnov.matches_Dvir.genome  Dnov.matches_Dame.genome | sort -u > Dnov.matches_Dvir_Dame.genome
comm -23 Dnov.all.singletons Dnov.matches_Dvir_Dame.genome > Dnov.true.singletons

#### now for americana #######
samtools faidx Dame.singletons.fa
cat Dame.singletons.fa.fai | awk '$2>=100 {print $1}' | sort -u > Dame.all.singletons

# get the sequences that are present in the vir genome

cat Dame.singletons_Dvir.genome.blastout | awk '{if($3>=80 && $4>=100) {print $0}}' | cut -f 2 | sort -u > Dame.matches_Dvir.genome

comm -23 Dame.all.singletons Dame.matches_Dvir.genome > Dame.notpresent_Dvir.genome

# get the sequences that are present in the nov genome

cat Dame.singletons_Dnov.genome.blastout | awk '{if($3>=80 && $4>=100) {print $0}}' | cut -f 2 | sort -u > Dame.matches_Dnov.genome

comm -23 Dame.all.singletons Dame.matches_Dnov.genome > Dame.notpresent_Dnov.genome

# now get the ame sequences that don't cluster with another and are not present in either nov or vir.
cat Dame.matches_Dvir.genome  Dame.matches_Dnov.genome | sort -u > Dame.matches_Dvir_Dnov.genome
comm -23 Dame.all.singletons Dame.matches_Dvir_Dnov.genome > Dame.true.singletons

mv *notpresent* /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/
mv *true.singletons /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/


cd ..
rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)