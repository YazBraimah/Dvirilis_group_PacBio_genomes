Dvir_genome_paper.Rmd / html: This is an Rmarkdown file that reproduces the TE-related figures and supplementary figures in the manuscript.  

ITR_array_lengths.sh : This script calculates the number and length of ITR arrays on each chromosome.  

ITR_insertion_analysis_G96-172TR.sh : This script searches for polymorphic insertions of ITRs in the three americana genomes. First, this script filters ITR loci that are found within 1kb of other TEs, which makes it challenging to find unique flanking sequences of novel insertions. Next, it takes 100 bp upstream and 100 bp downstream of each eligible ITR locus and concatenates them together. This concatenated sequence is blasted against the other two genomes. We manually checked the output files for continuous and high identity blast hits across the 200 bp sequence, indicating an uninserted homologous locus. We made similar scripts for pvB370 and the other three-way comparison combinations.  

singleton_virgroup_TEs.sh : This script if the first of three in the series which clusters combined TE libraries of virilis, novamexicana, and americana. It identifies the singleton sequences which do not cluster with any others. Next, it blasts the singleton sequences against the other two genomes. 

singleton_virgroup_TEs2.sh : The second script in the series identifies blast hits of putative singletons in the other species. If it has a blast hit of at least 100bp with at least 80% identity, the putatitive singleton is eliminated. 

singleton_virgroup_TEs3.sh : In the third script of the series, the abundance and percent divergence of the true singletons is queried in the genome it was originally found in. We manually filtered the singletons after this point.  

breakpoint_TE_analysis.sh : This script identifies transposable elements overlapping putatitive inversion breakpoints. The associated excel sheet shows the TE composition of the regions surrounding the breakpoints, which we make into a plot in the R markdown file. 
