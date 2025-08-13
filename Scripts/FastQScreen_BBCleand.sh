#!/bin/bash
#SBATCH --job-name=fastq_screen_loop
#SBATCH --account=def-gagnoned
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marym.allahyari@gmail.com

module load bowtie2
module load fastq-screen/0.16.0

for fq in /home/mallahya/scratch/SummerProject/final_bbmap_cleand/*.fastq.gz; do
    sample_name=$(basename "$fq" .fastq.gz)
    
    /home/mallahya/scratch/SummerProject/Tools/fastq-screen/FastQ-Screen-0.16.0/fastq_screen \
        --conf /home/mallahya/scratch/SummerProject/Tools/fastq-screen/FastQ-Screen-0.16.0/fastq_screen.conf \
        --aligner bowtie2 \
        --threads 8 \
        --subset 0 \
        --outdir /home/mallahya/scratch/SummerProject/FastQScreen_Outputs/bbmap_cleaned \
        "$fq" \
        &> /home/mallahya/scratch/SummerProject/Tools/fastq-screen/logs/${sample_name}_bbCleaned.log
done
