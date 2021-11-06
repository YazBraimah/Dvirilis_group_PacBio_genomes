#!/bin/bash -l
#SBATCH --job-name=ITR_arrays
#SBATCH --output=ITR_arrays.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=1000
#SBATCH --time=01:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02

#sbatch ITR_arrays.sh

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1
echo $2


#/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage
/programs/bin/labutils/mount_server cbsuclarkfs1 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/$1/$1PacBio_muller.fasta.out .

cat $1PacBio_muller.fasta.out | grep "Chr" | grep "Other" | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7 | bedtools sort -i stdin > $1.ITRs.bed

bedtools merge -i $1.ITRs.bed -d 200 | awk -v OFS="\t" '{print $1, $2, $3, $3-$2}' | awk '$4>100 {print $0}' > $1.ITRs.merged.filtered.bed

echo "arrays on Chr2:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_2" | wc -l

echo "average length of arrays (after merging) on Chr2:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_2" | awk '{sum += $4} END {print sum/NR}'

echo "arrays on Chr3:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_3" | wc -l

echo "average length of arrays (after merging) on Chr3:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_3" | awk '{sum += $4} END {print sum/NR}'

echo "arrays on Chr4:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_4" | wc -l

echo "average length of arrays (after merging) on Chr4:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_4" | awk '{sum += $4} END {print sum/NR}'

echo "arrays on Chr5:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_5" | wc -l

echo "average length of arrays (after merging) on Chr5:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_5" | awk '{sum += $4} END {print sum/NR}'

echo "arrays on Chr6:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_6" | wc -l

echo "average length of arrays (after merging) on Chr6:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_6" | awk '{sum += $4} END {print sum/NR}'

echo "arrays on ChrX:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_X" | wc -l

echo "average length of arrays (after merging) on ChrX:"
cat $1.ITRs.merged.filtered.bed | grep "Chr_X" | awk '{sum += $4} END {print sum/NR}'


cp $1.ITRs.merged.filtered.bed /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/$1/ITR_evolution

cd ..


rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)