#!/bin/bash -l
#SBATCH --job-name=TE_density_subclass_100kb_Dame
#SBATCH --output=TE_density_subclass_100kb_Dame.o%j
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=500
#SBATCH --time=00:20:00
#SBATCH --partition=short
#SBATCH --account=bscb02


# sbatch TE_density_subclass_10kb.sh <species> 

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1


/programs/bin/labutils/mount_server cbsufsrv5 /data1
/programs/bin/labutils/mount_server cbsubscb14 /storage


mkdir -p /workdir/$USER/$SLURM_JOB_ID
cd /workdir/$USER/$SLURM_JOB_ID

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/TEdensity/Dame_allbut_Chr5RC_masked.bed .
cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/TEdensity/Dame_Chr5_masked_RC_mod.bed .

cp /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/Dame/TEdensity/Dame_genome.ME.100kb.bed .


cat Dame_allbut_Chr5RC_masked.bed Dame_Chr5_masked_RC_mod.bed | sort -k1,1 -k2,2n > Dame_genome.masked.bed


# need to sed replace DINE with RC
# where does the sorting become wrong??

# intersect them
bedtools intersect -a $1_genome.ME.100kb.bed -b $1_genome.masked.bed -wao | awk '$5!=-1 {print $0}' | cut -f 1,2,3,7,8,10 | sed 's|\t|'$'-''|' | sed 's|\t|'$'-''|' > $1_masked.intersected

class="LTR LINE RC DNA Other Unknown"

intervals=`cat $1_masked.intersected | cut -f 1 | sed 's|'-'|\t|g' | sort -k1,1 -k2,2n -u | sed 's|\t|'-'|g'`

## note: might also want to get the size of each region so can divide by that number.
for i in $intervals
do
	echo $i > $i.file
	cat $1_masked.intersected | awk -v i="$i" '$1==i {print $0}' | head -n 1 | cut -f 1 | sed 's|'-'|\t|g' | awk '{print $3-$2}' > $i.size
	cat $1_masked.intersected | awk -v i="$i" '$1==i {print $0}' | awk -v OFS="\t" '{if ($3 ~ /\//) {split ($3,a,"/"); print $1,$2,a[1],$4} else {print $0}}' > $i.bed 
	
	for c in $class
	do
		if grep -q "$c" $i.bed
		then
			cat $i.bed | awk -v c="$c" '$3==c {print $4}' | awk '{sum += $1} END {print sum}' > $c.sum
		else
			echo 0 > $c.sum
		fi
		    # match to the class, then add up the base pairs
	done
	# then print into a nice file
	paste $i.file LTR.sum LINE.sum RC.sum DNA.sum Other.sum Unknown.sum >> $1_100kb.intervals_TE.density.redo
	paste $i.file $i.size >> $1_100kb.intervals.sizes.redo
done


#cp $1_masked.intersected /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/$1/TEdensity
cp *intervals.sizes.redo /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/$1/TEdensity
cp *intervals_TE.density.redo /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/$1/TEdensity
cp Dame_genome.masked.bed /fs/cbsubscb14/storage/jmf422/Drosophila_TEs/$1/TEdensity/Dame_genome.masked.RCmod.bed

cd ..


rm -r ./$SLURM_JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)