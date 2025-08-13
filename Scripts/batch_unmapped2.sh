#!/bin/bash

#SBATCH --account=def-gagnoned
#SBATCH --job-name=extract_unmapped
#SBATCH --output=logs/extract_unmapped_%A_%a.out
#SBATCH --error=logs/extract_unmapped_%A_%a.err
#SBATCH --time=6:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marym.allahyari@gmail.com

module load samtools

# Navigate to working directory
cd /home/mallahya/scratch/Data/field_collected_bam_files/

# Make sure output folder exists
mkdir -p unmapped

# List all proper BAM input files (ignore .bam.bai)
bam_files=($(ls *.bam | grep -v ".bam.bai"))

# Max parallel jobs
max_threads=4
thread_count=0

# Function to process each sample
process_sample() {
    bamfile="$1"
    sample=$(basename "$bamfile" .bam)
    echo "Processing sample: $sample"

    outbam="unmapped/${sample}_unmapped_pairs.bam"
    outfq1="unmapped/${sample}_unmapped_R1.fq"
    outfq2="unmapped/${sample}_unmapped_R2.fq"

    # Extract unmapped reads
    samtools view -b -f 12 -F 256 "$bamfile" > "$outbam"

    # Convert to FASTQ
    samtools fastq \
        -1 "$outfq1" \
        -2 "$outfq2" \
        -0 /dev/null -s /dev/null -n \
        "$outbam"

    echo "Finished sample: $sample"
}

# Run loop with controlled parallelism
for bamfile in "${bam_files[@]}"; do
    process_sample "$bamfile" &

    ((thread_count++))
    if (( thread_count >= max_threads )); then
        wait
        thread_count=0
    fi
done

wait
echo "✅ All samples processed."
