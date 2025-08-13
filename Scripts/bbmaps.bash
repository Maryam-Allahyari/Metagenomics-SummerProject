#!/bin/bash
#SBATCH --job-name=Solanum_BBmap_vir2
#SBATCH --account=def-gagnoned      
#SBATCH --time=24:00:00           
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=10
#SBATCH --mem=24G
#SBATCH --output=logs/%x_%j.out
#SBATCH --error=logs/%x_%j.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marym.allahyari@gmail.com

# Ensure output directories exist
mkdir -p logs MAPPED UNMAPPED

# Set number of threads
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

source biokit_env/bin/activate

# Load required modules
module load bbmap

echo "Running BBMap on Rodrigo's Potato dataset..."

# Optional: Remove any prior output (optional safety check)
# parallel rm -r {} ::: MAPPED/* UNMAPPED/*

# Index the reference only once
bbmap.sh ref=All_Combined.fasta

# Loop through samples in namelist.txt
while read sample; do
    echo "Processing $sample..."

    # Run BBMap with multithreading
    bbmap.sh in=${sample}.fastq.gz \
             outm=${sample}_mapped.fastq.gz \
             outu=${sample}_unmapped.fastq.gz \
             threads=$SLURM_CPUS_PER_TASK

    # Move results to respective folders
    mv ${sample}_mapped.fastq.gz MAPPED/
    mv ${sample}_unmapped.fastq.gz UNMAPPED/

done < namelist.txt

echo "DONE!"
seff $SLURM_JOB_ID
