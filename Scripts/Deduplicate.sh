#!/bin/bash

#SBATCH --account=def-gagnoned
#SBATCH --job-name=Deduplicate
#SBATCH --output=logs/dedup.out
#SBATCH --error=logs/dedup.err
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=24G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marym.allahyari@gmail.com


# Load required modules (on Compute Canada or similar HPC)
module load java/1.8
module load samtools

# Path to Picard
PICARD_JAR="/home/mallahya/scratch/Tool/picard.jar"  

# Define directories
INPUT_DIR="/home/mallahya/scratch/Data/new_herbar/80s"
OUTPUT_DIR="/home/mallahya/scratch/Data/new_herbar/80s/dedup"
LOG_DIR="${OUTPUT_DIR}/picard_logs"
FASTQ_DIR="${OUTPUT_DIR}/fq"
FQ_ZIP_DIR="${OUTPUT_DIR}/fq_gz"


# Loop over all *_unmapped_pairs.bam files in INPUT_DIR
for bam in ${INPUT_DIR}/*_unmapped_pairs.bam; do
    sample=$(basename "$bam" _unmapped_pairs.bam)

    echo "Processing sample: $sample"

    # Step 1: Mark duplicates with Picard
    java -jar "$PICARD_JAR" MarkDuplicates \
        I="$bam" \
        O="${OUTPUT_DIR}/${sample}_unmapped_dedup.bam" \
        M="${LOG_DIR}/${sample}_metrics.txt" \
        REMOVE_DUPLICATES=true \
        CREATE_INDEX=true \
        VALIDATION_STRINGENCY=SILENT

    # Step 2: Convert deduplicated BAM to FASTQ (paired)
    samtools fastq -@ 8 \
        -1 "${FASTQ_DIR}/${sample}_unmapped_dedup_R1.fastq" \
        -2 "${FASTQ_DIR}/${sample}_unmapped_dedup_R2.fastq" \
        -0 /dev/null -s /dev/null -n \
        "${OUTPUT_DIR}/${sample}_unmapped_dedup.bam"

    # Step 3: Compress the FASTQ files
    gzip -c "${FASTQ_DIR}/${sample}_unmapped_dedup_R1.fastq" > "${FQ_ZIP_DIR}/${sample}_unmapped_dedup_R1.fastq.gz"
    gzip -c "${FASTQ_DIR}/${sample}_unmapped_dedup_R2.fastq" > "${FQ_ZIP_DIR}/${sample}_unmapped_dedup_R2.fastq.gz"

    echo "$sample processing is done."
done
