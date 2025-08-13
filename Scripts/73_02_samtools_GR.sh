#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=samtools
#SBATCH --output=01_samtoolsGR_73.out
#SBATCH --error=01_SamtoolsGR_73.err
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=168:0:00
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-user=edeline.gagnon@gmail.com


#The following script is for cleaning reads with the program leeHom, on ancient DNA settings.
	### Edeline Gagnon- 26 Mars 2024
	
#Load relevant modules
module load bwa
module load samtools

#Navigate to output location
#cd /lustre06/project/6087481/gagnoned/Museomics_Schilense/raw/73/

#Then I mapped the reference I got using bwa:

#Unmerge these lines if you've not indexed the reference
#cd $HOME/projects/def-gagnon/gagnoned/Schilense_reference_DT
#cp -r /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/
#bwa index /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/S_chilense_reference.fasta

cd /lustre07/scratch/gagnoned/Schilense_Herb/leehom

samtools merge -o 73_Lee.bam <( nice -n 19 bwa samse /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/S_chilense_reference.fasta  <(nice -n 19 bwa aln  -n 0.01 -o 2 -l 16500 -t 28 /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/S_chilense_reference.fasta 73_Lee.fq.gz )  73_Lee.fq.gz |samtools sort - ) <( nice -n 19 bwa sampe /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/S_chilense_reference.fasta <(nice -n 19 bwa aln  -n 0.01 -o 2 -l 16500 -t 16 /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/S_chilense_reference.fasta 73_Lee_r1.fq.gz )  <(nice -n 19 bwa aln  -n 0.01 -o 2 -l 16500 -t 16 /lustre07/scratch/gagnoned/Schilense_Herb/reference_data/S_chilense_reference.fasta 73_Lee_r2.fq.gz ) 73_Lee_r1.fq.gz 73_Lee_r2.fq.gz  |samtools sort - )


#This took 5days and 3 hours to run.