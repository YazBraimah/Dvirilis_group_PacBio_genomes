#!/bin/bash -l
#SBATCH --job-name=ITR_insertion_analysis_G96-172TR
#SBATCH --output=ITR_insertion_analysis_G96-172TR.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=1000
#SBATCH --time=01:00:00
#SBATCH --partition=short
#SBATCH --account=bscb02

# qsub ITR_insertion_analysis2.sh 

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/DamePacBio_muller.fasta.out .

cat DamePacBio_muller.fasta.out | grep "Chr" | grep "Other" | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7,10,11 > Dame_G96_other_chr.bed

cat Dame_G96_other_chr.bed | grep '172TR' | sort -k1,1 -k2,2n | bedtools merge -i stdin -d 100 > Dame_G96_172TR_chr.bed
cat Dame_G96_other_chr.bed | grep 'pvB370'| sort -k1,1 -k2,2n | bedtools merge -i stdin -d 100 > Dame_G96_pvB370_chr.bed


# need to make a bed file containing all the repeats EXCEPT the 172TR and pvB370


cat DamePacBio_muller.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7,10,11 | grep -v 'pvB370' | cut -f 1,2,3 > DamePacBio_G96_ME.allothers1.bed

cat DamePacBio_muller.fasta.out | sed -e 1,3d | sed -e 's/^[ \t]*//' | tr -s " " | sed 's| |\t|g' | cut -f 5,6,7,10,11 | grep -v '172TR' | cut -f 1,2,3 > DamePacBio_G96_ME.allothers2.bed

#cat Dame_ML975_pvB370_chr.bed Dame_ML975_172TR_chr.bed | sort -k1,1 -k2,2n > Dame_ML975_ITRs.bed


bedtools window -a Dame_G96_pvB370_chr.bed -b DamePacBio_G96_ME.allothers1.bed -v > Dame_G96_pvB370_chr.window.bed


bedtools window -a Dame_G96_172TR_chr.bed -b DamePacBio_G96_ME.allothers2.bed -v > Dame_G96_172TR_chr.window.bed


### get the genome fastas - start editing here

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/nanopore_genomes/DameNanopore_SB0206_canu.ME.fa.gz .
gunzip DameNanopore_SB0206_canu.ME.fa.gz

cat DameNanopore_SB0206_canu.ME.fa | sed 's/>.*/&_SB0206/' > DameNanopore_SB0206_canu.ME2.fa


cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/nanopore_genomes/DameNanopore_ML975_canu.ME.fa.gz .
gunzip DameNanopore_ML975_canu.ME.fa.gz
cat DameNanopore_ML975_canu.ME.fa | sed 's/>.*/&_ML975/' > DameNanopore_ML975_canu.ME2.fa


cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/DamePacBio_muller.fasta .
cat DamePacBio_muller.fasta | sed 's/>.*/&_G96/' > DamePacBio_muller2.fasta

## next make a fasta file of the flanking regions put together

# this might be useful: https://stackoverflow.com/questions/40588191/concatenating-multiple-files-into-a-single-line-in-linux

#https://www.biostars.org/p/294920/


######## next combination: #######

while read line;
do
	region=`echo $line | sed 's/ /_/g'`
	#echo $region
	#get upstream
	echo $line | awk -v OFS="\t" -v region="$region" '{if($2>100) {print $1,$2-100,$2,region}}' > upstream.bed # problem with a couple lines. start at 1. need an if statement.
	# get downstream
	echo $line | awk -v OFS="\t" -v region="$region" '{print $1,$3+1,$3+101,region}' > downstream.bed
	# comebine the bed
	cat upstream.bed downstream.bed > flanking.bed
	cat flanking.bed
	#bedtools get fasta
	bedtools getfasta -fi DamePacBio_muller.fasta -bed flanking.bed -nameOnly -fo flanking.fa
	# combine the fasta
	/programs/emboss/bin/union -filter flanking.fa > $region.fa # check this now
done < 	Dame_G96_172TR_chr.window.bed

cat Chr_*_*_*.fa > Dame_G96_172TR.flanking.fa

# copy the intermediate files

# great, time to blast against the other genomes

cat DameNanopore_ML975_canu.ME2.fa DameNanopore_SB0206_canu.ME2.fa > ML975.SB0206_combined.fa

makeblastdb -dbtype nucl -in Dame_G96_172TR.flanking.fa

blastn -db Dame_G96_172TR.flanking.fa -query ML975.SB0206_combined.fa -outfmt 6 -out DameNanopore_G96_172TR-others.blast.out



cp DameNanopore_G96_172TR-others.blast.out /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/nanopore_genomes/test_window

#less DameNanopore_ML975_pvB379-SBO206.blast.out | cut -f 2 | sort | uniq -c | less
#less DameNanopore_ML975_pvB379-SBO206.blast.out | awk '$4>150 {print $0}' | cut -f 2 | sort | uniq -c | less




cd ..


rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)