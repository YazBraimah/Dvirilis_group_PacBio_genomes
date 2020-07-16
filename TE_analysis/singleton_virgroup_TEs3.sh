#!/bin/bash -l
#SBATCH --job-name=singleton_virgroup_TEs3
#SBATCH --output=singleton_virgroup_TEs3.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=500
#SBATCH --time=00:10:00
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

mkdir -p /workdir/$USER/$SLURM_JOB_ID

cd /workdir/$USER/$SLURM_JOB_ID

# get the true singletons for each species

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/*true.singletons .

# get the parsed output
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/Dvir_genome.fa.out.parseRM.all-repeats.tab .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/Dame_genome.fa.out.parseRM.all-repeats.tab .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dnov/Dnov_genome.fa.out.parseRM.all-repeats.tab .

cat Dvir.true.singletons | sed 's/Dvir/family/g' > Dvir.true2.singletons
cat Dnov.true.singletons | sed 's/Dnov/family/g' > Dnov.true2.singletons
cat Dame.true.singletons | sed 's/Dame/family/g' > Dame.true2.singletons

# now grep them in the file, or use awk

grep -w -f Dvir.true2.singletons Dvir_genome.fa.out.parseRM.all-repeats.tab | cut -f 1-8 > Dvir.true.singletons.parsed.summary
grep -w -f Dnov.true2.singletons Dnov_genome.fa.out.parseRM.all-repeats.tab | cut -f 1-8 > Dnov.true.singletons.parsed.summary
grep -w -f Dame.true2.singletons Dame_genome.fa.out.parseRM.all-repeats.tab | cut -f 1-8 > Dame.true.singletons.parsed.summary


cp *parsed.summary /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/


cd ..
rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)