#!/bin/bash -l
#SBATCH --job-name=singleton_virgroup_TEs
#SBATCH --output=singleton_virgroup_TEs.o%j
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

# copy out the output
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/virgroup_TE_clusters.* .

# get the singleton sequences

csplit --digits=4 --quiet --prefix=clstr virgroup_TE_clusters.fa.clstr "/^>/" "{*}"

rm clstr0000


for f in clstr????
do
	if ! grep -q '^1' $f; then
	cat $f | sed '1d' | cut -f 2 -d '>'  | cut -f 1 -d '#' >> singleton.seqs
	fi
done

echo "number of singleton sequences:"
wc -l singleton.seqs

cat singleton.seqs | grep 'Dvir' > Dvir.singletons
cat singleton.seqs | grep 'Dnov' > Dnov.singletons
cat singleton.seqs | grep 'Dame' > Dame.singletons

#get the singleton sequences from the file

# need to remove the classification because it's cut off. 
cat virgroup_TE_clusters.fa | cut -f 1 -d '#' > virgroup_TE_clusters.mod.fa

# now let's get the singleton sequences in a fasta
xargs samtools faidx virgroup_TE_clusters.mod.fa < Dvir.singletons > Dvir.singletons.fa
xargs samtools faidx virgroup_TE_clusters.mod.fa < Dnov.singletons > Dnov.singletons.fa
xargs samtools faidx virgroup_TE_clusters.mod.fa < Dame.singletons > Dame.singletons.fa

# now let's blast them to the genome assemblies

#copy in the genome assemblies
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/DvirPacBio_muller.fasta .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dnov/DnovPacBio_muller.fasta .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/DamePacBio_muller.fasta .

# virilis singletons against nov genome

makeblastdb -dbtype nucl -in Dvir.singletons.fa

blastn -db Dvir.singletons.fa -query DnovPacBio_muller.fasta -outfmt 6 -out Dvir.singletons_Dnov.genome.blastout

# virilis singletons against ame genome

blastn -db Dvir.singletons.fa -query DamePacBio_muller.fasta -outfmt 6 -out Dvir.singletons_Dame.genome.blastout


# nov singletons against virilis genome

makeblastdb -dbtype nucl -in Dnov.singletons.fa

blastn -db Dnov.singletons.fa -query DvirPacBio_muller.fasta -outfmt 6 -out Dnov.singletons_Dvir.genome.blastout

# nov singletons against ame genome
blastn -db Dnov.singletons.fa -query DamePacBio_muller.fasta -outfmt 6 -out Dnov.singletons_Dame.genome.blastout

# ame singletons against virilis genome
makeblastdb -dbtype nucl -in Dame.singletons.fa

blastn -db Dame.singletons.fa -query DvirPacBio_muller.fasta -outfmt 6 -out Dame.singletons_Dvir.genome.blastout

# ame singletons against nov genome
blastn -db Dame.singletons.fa -query DnovPacBio_muller.fasta -outfmt 6 -out Dame.singletons_Dnov.genome.blastout

mv *singletons.fa /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/
mv *blastout /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/trispecies_clustering/



cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)