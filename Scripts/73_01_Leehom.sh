#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=leeHOM
#SBATCH --output=leeHOM_73_2025.out
#SBATCH --error=leeHOM_73_2025.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=24:0:00

#The following script is for cleaning reads with the program leeHom, on ancient DNA settings.
	### Edeline Gagnon- 26 Mars 2024
	
#Load relevant modules
module load apptainer

#Navigate to output location
cd /lustre06/project/6087481/gagnoned/Museomics_Schilense/raw/73/

# LeeHom
apptainer exec /lustre06/project/6087481/gagnoned/grenaud-tools.sif leeHom --ancientdna --auto -t 3 -fq1 73_1.fq.gz -fq2 73_2.fq.gz -fqo /lustre07/scratch/gagnoned/Schilense_Herb/leehom/73_Lee

#########################
# Next step is the samtools step (73_01_samtools_GR.sh)
#This step took 1hour 10 minutes to run, total CPU 4:38:14.
