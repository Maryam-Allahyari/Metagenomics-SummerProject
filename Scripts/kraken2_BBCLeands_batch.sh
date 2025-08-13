#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=kraken2_BBcleaned
#SBATCH --cpus-per-task=8
#SBATCH --mem=96G
#SBATCH --time=2:00:00 
#SBATCH --array=0-12
#SBATCH --output=kraken2_logs/%A_%a.out
#SBATCH --error=kraken2_logs/%A_%a.err
#SBATCH --mail-type=ALL 
#SBATCH --mail-user=marym.allahyari@gmail.com


# Load required modules
module load kraken2

# Sample IDs 
SAMPLES=(33 70 73 71_317 73_319 75_322 76_324 77_325 78_326 79_327 80_328 81_329 85_321-06)
SAMPLE=${SAMPLES[$SLURM_ARRAY_TASK_ID]}

# Paths
IN_DIR="/home/mallahya/scratch/SummerProject/final_bbmap_cleand"
OUT_DIR="/home/mallahya/scratch/SummerProject/Kraken2_output/BBCleaned/"
DB_PATH="/home/mallahya/scratch/SummerProject/Tools/Kraken2_Db/"

# Make sure output and log directories exist
mkdir -p "$OUT_DIR/logs"

# Input FASTQ file paths
R1="${IN_DIR}/${SAMPLE}_R1_unmapped.fastq.gz"
R2="${IN_DIR}/${SAMPLE}_R2_unmapped.fastq.gz"

# Output paths
REPORT="${OUT_DIR}/${SAMPLE}_kraken2_report.txt"
OUTPUT="${OUT_DIR}/${SAMPLE}_kraken2_output.txt"
LOG="${OUT_DIR}/logs/${SAMPLE}_kraken2.log"
ERR="${OUT_DIR}/logs/${SAMPLE}_kraken2.err"

echo "Running Kraken2 for sample $SAMPLE"

# Run Kraken2 classification
kraken2 \
  --db "$DB_PATH" \
  --threads 8 \
  --paired "$R1" "$R2" \
  --use-names \
  --report "$REPORT" \
  --output "$OUTPUT" > "$LOG" 2> "$ERR"

echo "Finished Kraken2 for sample $SAMPLE"
