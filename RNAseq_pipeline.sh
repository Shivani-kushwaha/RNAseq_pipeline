#!/bin/bash

SECONDS=0
# change working directory
cd /Users/shivanikushwaha/Documents/Documents_Shivani/RNA_bulk_pipeline

# STEP 1: Run fastqc
fastqc data/demo.fastq -o data/

# run trimmomatic to trim reads with poor quality
java -jar /Users/shivanikushwaha/Documents/Documents_Shivani/apps/Trimmomatic-0.39/trimmomatic-0.39.jar SE -threads 4 data/demo.fastq data/demo_trimmed.fastq TRAILING:10 -phred33
echo "Trimmomatic finished running!"

# run fastqc again
fastqc data/demo_trimmed.fastq -o data/

#step 2: HISAT2 alignment
# run hisat2 and get the genome indices
# wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz
# dowloaded hisat2 using bioconda 
hisat2=/Users/shivanikushwaha/opt/anaconda3/envs/py3.7/bin/hisat2
hisat2 -q --rna-strandness R -x HISAT2/grch38/genome -U data/demo_trimmed.fastq | samtools sort -o HISAT2/demo_trimmed.bam
echo "HISAT2 finished running!"

# STEP 3: Run featureCounts - Quantification and get the gene annotation file: gtf
# wget https://ftp.ensembl.org/pub/release-110/gtf/homo_sapiens/Homo_sapiens.GRCh38.110.gtf.gz
# downloaded featurecount using conda 
featurecounts=/Users/shivanikushwaha/opt/anaconda3/envs/featurecounts/bin/featureCounts
featureCounts -S 2 -a Homo_sapiens.GRCh38.110.gtf -o quants/demo_featurecounts.txt HISAT2/demo_trimmed.bam
echo "featureCounts finished running!"

duration=$SECONDS
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

