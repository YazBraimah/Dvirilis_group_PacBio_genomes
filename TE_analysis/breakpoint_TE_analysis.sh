#!/bin/bash -l
#SBATCH --job-name=breakpoint_TE_analysis
#SBATCH --output=breakpoint_TE_analysis.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=2000
#SBATCH --time=04:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02



#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/breakpoints/rearrangement_breakpoints_touse.txt .

# first, get the virilis reference breakpoints

cat rearrangement_breakpoints_touse.txt | awk '$5=="Dvir" {print $0}' | awk -v OFS="\t"  '{if($7>$8) {print $4,$8,$7,$2,$3,$6} else {print $4,$7,$8,$2,$3,$6}}' | sort -k1,1 -k2,2n > Dvir_ref_breakpoints.bed

# bring in the masked virilis genome
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/DvirPacBio_muller.fasta.out .

# make a bed file with it
cat DvirPacBio_muller.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7,10,11 | sort -k1,1 -k2,2n > Dvir_masking.bed

bedtools closest -a Dvir_ref_breakpoints.bed -b Dvir_masking.bed -d > Dvir_ref_breakpoints_TEs.closest
# b is TEs, a is breakpoints

# now novamexicana breakpoints

cat rearrangement_breakpoints_touse.txt | awk '$5=="Dnov" {print $0}' | awk -v OFS="\t"  '{if($7>$8) {print $4,$8,$7,$2,$3,$6} else {print $4,$7,$8,$2,$3,$6}}'| sort -k1,1 -k2,2n > Dnov_ref_breakpoints.bed

# bring in the masked virilis genome
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dnov/DnovPacBio_muller.fasta.out .

# make a bed file with it
cat DnovPacBio_muller.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7,10,11 | sort -k1,1 -k2,2n > Dnov_masking.bed

bedtools closest -a Dnov_ref_breakpoints.bed -b Dnov_masking.bed -d > Dnov_ref_breakpoints_TEs.closest
# b is TEs, a is breakpoints

# now americana breakpoints

cat rearrangement_breakpoints_touse.txt | awk '$5=="Dame" {print $0}' | awk -v OFS="\t"  '{if($7>$8) {print $4,$8,$7,$2,$3,$6} else {print $4,$7,$8,$2,$3,$6}}' | sort -k1,1 -k2,2n > Dame_ref_breakpoints.bed

# bring in the masked virilis genome
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/DamePacBio_muller.fasta.out .

# make a bed file with it
cat DamePacBio_muller.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7,10,11 | sort -k1,1 -k2,2n > Dame_masking.bed

bedtools closest -a Dame_ref_breakpoints.bed -b Dame_masking.bed -d > Dame_ref_breakpoints_TEs.closest
# b is TEs, a is breakpoints

cp *closest /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dvir/breakpoints/

cd ..


rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)