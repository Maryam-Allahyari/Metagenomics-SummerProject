#!/bin/bash
#SBATCH --account=def-gagnoned
#SBATCH --job-name=qiime2_TreeDecon
#SBATCH --output=qiime2_TreeDecon_%j.out
#SBATCH --error=qiime2_TreeDecon_%j.err
#SBATCH --cpus-per-task=4
#SBATCH --mem=24G
#SBATCH --time=1:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=marym.allahyari@gmail.com

# Load QIIME2 module and apptainer container
module load qiime2
module load apptainer

# Set input/output paths
BIOM_FILE="/scratch/mallahya/SummerProject/biom_output/final_18_dirty.biom"
OUTPUT_DIR="/scratch/mallahya/SummerProject/QIIME2_output/Run10_clean_depth3000"
METADATA_FILE="/scratch/mallahya/SummerProject/QIIME2_output/metadata.tsv"

mkdir -p "$OUTPUT_DIR"

# Step 1: Import BIOM as FeatureTable
qiime tools import \
  --input-path "$BIOM_FILE" \
  --type 'FeatureTable[Frequency]' \
  --input-format BIOMV210Format \
  --output-path "$OUTPUT_DIR/samples_freq.qza"

# Step 2: Import BIOM again as taxonomy
qiime tools import \
  --input-path "$BIOM_FILE" \
  --type 'FeatureData[Taxonomy]' \
  --input-format BIOMV210Format \
  --output-path "$OUTPUT_DIR/samples_tax.qza"

# Step 2.5: Remove contaminants
qiime taxa filter-table \
  --i-table "$OUTPUT_DIR/samples_freq.qza" \
  --i-taxonomy "$OUTPUT_DIR/samples_tax.qza" \
  --p-exclude Chordata,Alternaria,Albugo,Aspergillus,Aureimonas,Streptococcus \
  --o-filtered-table "$OUTPUT_DIR/samples_freq_filtered.qza"

# Step 3: Summarize feature table
qiime feature-table summarize \
  --i-table "$OUTPUT_DIR/samples_freq_filtered.qza" \
  --o-visualization "$OUTPUT_DIR/table_summary.qzv"

# Step 4: Create taxonomic barplot
qiime taxa barplot \
  --i-table "$OUTPUT_DIR/samples_freq_filtered.qza" \
  --i-taxonomy "$OUTPUT_DIR/samples_tax.qza" \
  --m-metadata-file "$METADATA_FILE" \
  --o-visualization "$OUTPUT_DIR/taxa_barplot.qzv"

# Step 5: Run core diversity metrics (alpha, beta, etc.)
qiime diversity core-metrics \
  --i-table "$OUTPUT_DIR/samples_freq_filtered.qza" \
  --p-sampling-depth 3000 \
  --m-metadata-file "$METADATA_FILE" \
  --output-dir "$OUTPUT_DIR/core_diversity"

# Step 6: Alpha diversity group comparison (Shannon)
qiime diversity alpha-group-significance \
  --i-alpha-diversity "$OUTPUT_DIR/core_diversity/shannon_vector.qza" \
  --m-metadata-file "$METADATA_FILE" \
  --o-visualization "$OUTPUT_DIR/shannon_groups.qzv"

# Step 7: Beta diversity group comparison (Bray-Curtis)
qiime diversity beta-group-significance \
  --i-distance-matrix "$OUTPUT_DIR/core_diversity/bray_curtis_distance_matrix.qza" \
  --m-metadata-file "$METADATA_FILE" \
  --m-metadata-column group \
  --o-visualization "$OUTPUT_DIR/bray_groups.qzv"

# Step 8:
#qiime phylogeny align-to-tree-mafft-fasttree \
#  --i-sequences "$OUTPUT_DIR/rep_seqs.qza" \
#  --o-alignment "$OUTPUT_DIR//aligned_rep_seqs.qza" \
#  --o-masked-alignment "$OUTPUT_DIR/masked_aligned_rep_seqs.qza" \
#  --o-tree "$OUTPUT_DIR/unrooted_tree.qza" \
#  --o-rooted-tree "$OUTPUT_DIR/rooted_tree.qza"

# Step 9:tree in diversity metrics
#qiime diversity core-metrics-phylogenetic \
#  --i-table "$OUTPUT_DIR/samples_freq_filtered.qza" \
#  --i-phylogeny "$OUTPUT_DIR/rooted_tree.qza" \
#  --m-metadata-file "$METADATA_FILE" \
#  --p-sampling-depth 10000 \
#  --output-dir "$OUTPUT_DIR/core_diversity"

echo "QIIME2 is done!!"
