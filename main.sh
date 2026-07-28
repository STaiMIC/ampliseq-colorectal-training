#!/bin/bash
#
# main.sh
# ~~~~~~~
# Single entry script for the Ampliseq 16S training pipeline.
# Students only need to run:
#
#     bash main.sh
#
# This runs the OFFICIAL nf-core/ampliseq test dataset — same pipeline,
# same parameters, same workflow you'd use on real data, just without
# needing to download gigabytes of FASTQ files during a live class.
#
# The samplesheet.csv and Metadata.tsv in data/ are teaching examples
# only — they show you the exact file structure ampliseq expects for
# YOUR OWN data. See README.md for the full command you'd run against
# real files.

set -e

###############################################################################
# Repository location
###############################################################################

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

###############################################################################
# Banner
###############################################################################

echo ""
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║          Ampliseq 16S Microbiome Training                          ║"
echo "║                                                                    ║"
echo "║     FASTQ → ASVs → QC/Decontam → Diversity-ready outputs           ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

###############################################################################
# Check software
###############################################################################

echo "Checking required software..."
echo ""

if ! command -v nextflow >/dev/null 2>&1; then
    echo "❌ ERROR: Nextflow is not installed."
    echo ""
    echo "Install it with:"
    echo "curl -fsSL https://get.nextflow.io | bash"
    exit 1
fi

echo "✓ Nextflow version:"
nextflow -version 2>&1 | head -1

echo "✓ Java:"
java -version 2>&1 | head -1

if ! command -v docker >/dev/null 2>&1; then
    echo ""
    echo "❌ ERROR: Docker is not installed."
    exit 1
fi

echo "✓ Docker:"
docker --version

###############################################################################
# Check Docker daemon
###############################################################################

echo ""

if ! docker ps >/dev/null 2>&1; then
    echo "❌ ERROR: Docker daemon is not running."
    echo ""
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo "✓ Docker daemon is running"

###############################################################################
# Check internet connection
###############################################################################

echo ""
echo "Checking internet connection..."

if ! curl -Is https://github.com >/dev/null 2>&1; then
    echo "❌ ERROR: Internet connection unavailable."
    echo ""
    echo "Nextflow needs internet access the first time it downloads"
    echo "the nf-core/ampliseq pipeline and its official test data."
    exit 1
fi

echo "✓ Internet connection available"

###############################################################################
# What you'd run on YOUR OWN data (reference only — not executed here)
###############################################################################

echo ""
echo "────────────────────────────────────────────────────────────────────"
echo "  Reference: this is the command you'd run on your OWN FASTQ data"
echo "  (see data/samplesheet.csv and data/Metadata.tsv for file format)"
echo "────────────────────────────────────────────────────────────────────"
echo ""
echo '  nextflow run nf-core/ampliseq -r 2.18.0 \'
echo '      -profile docker \'
echo '      --input data/samplesheet.csv \'
echo '      --metadata data/Metadata.tsv \'
echo '      --metadata_category status \'
echo '      --FW_primer GTGYCAGCMGCCGCGGTAA \'
echo '      --RV_primer GGACTACNVGGGTWTCTAAT \'
echo '      --dada_ref_taxonomy silva=138 \'
echo '      --outdir results'
echo ""
echo "────────────────────────────────────────────────────────────────────"
echo "  Today's live run uses the official nf-core/ampliseq test dataset"
echo "  instead — same pipeline, same steps, no multi-GB download needed."
echo "────────────────────────────────────────────────────────────────────"
echo ""

###############################################################################
# Display pipeline overview
###############################################################################

echo "Pipeline steps that will run today:"
echo ""
echo "  1. FASTQC                 Assess raw read quality"
echo "  2. Cutadapt               Remove primer sequences"
echo "  3. DADA2                  Filter, denoise, merge, infer ASVs, remove chimeras"
echo "  4. Barrnap                Screen ASVs for rRNA gene content (BARRNAPSUMMARY)"
echo "  5. Decontam                Flag/remove likely contaminant ASVs"
echo "  6. MultiQC                Aggregate quality reports"
echo "  7. Summary Report          Overall run summary (overall_summary.tsv)"
echo ""
echo "  SKIPPED today, on purpose, because of Codespace resource limits:"
echo ""
echo "    --skip_taxonomy   Skips DADA2's own SILVA-based taxonomy"
echo "                      classification. Downloading + running the"
echo "                      SILVA 138 reference against even the small"
echo "                      test dataset was pushing past our 40-min"
echo "                      process time limit on Codespaces hardware."
echo ""
echo "    --skip_qiime      Skips ALL QIIME2 secondary analysis: training"
echo "                      a classifier from scratch, barplots, alpha/beta"
echo "                      diversity, differential abundance. QIIME2_TRAIN"
echo "                      alone can run well past an hour even on the"
echo "                      tiny official test dataset — incompatible with"
echo "                      a 45-60 min live class window."
echo ""
echo "  Both are FULL PIPELINE FEATURES you'd normally use on real data —"
echo "  we're skipping them today purely for classroom time/resource"
echo "  constraints, not because they aren't part of ampliseq. See the"
echo "  toggle notes just above the pipeline call below to re-enable them."
echo ""
echo "Pipeline starting..."
echo ""

###############################################################################
# Run nf-core/ampliseq on the OFFICIAL test dataset
###############################################################################
#
# --skip_taxonomy AND --skip_qiime TOGGLES
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Both of these are switched OFF for today's live demo purely because of
# Codespace resource/time limits — not because they're optional extras.
#
#   --skip_taxonomy   Skips DADA2's built-in SILVA classifier step.
#                      On modest Codespace hardware, downloading the SILVA
#                      138 reference and classifying — even against the
#                      tiny test dataset — was blowing past our 40.min
#                      process time limit set in nextflow.config.
#
#   --skip_qiime      Skips QIIME2_EXTRACT / QIIME2_TRAIN (training a
#                      taxonomy classifier from scratch) plus all QIIME2
#                      diversity analysis (barplots, alpha/beta diversity,
#                      differential abundance). This is the single heaviest
#                      part of the whole pipeline — it can run past an hour
#                      on modest hardware even on the tiny test dataset.
#
# TO RUN THE FULL PIPELINE (taxonomy + QIIME2 diversity analysis) OUTSIDE
# CLASS TIME CONSTRAINTS: remove the --skip_taxonomy and --skip_qiime lines
# below, and either raise nextflow.config's process time limit well above
# 40.min, or run overnight / on a beefier machine. Budget 1-2+ hours extra.

nextflow run nf-core/ampliseq \
    -r 2.18.0 \
    -profile docker \
    --input https://raw.githubusercontent.com/nf-core/test-datasets/ampliseq/samplesheets/Samplesheet_standardized.tsv \
    --metadata https://raw.githubusercontent.com/nf-core/test-datasets/ampliseq/samplesheets/Metadata.tsv \
    --FW_primer GTGYCAGCMGCCGCGGTAA \
    --RV_primer GGACTACNVGGGTWTCTAAT \
    --outdir results \
    --skip_taxonomy \
    --skip_qiime \
    -resume

###############################################################################
# Finished
###############################################################################

echo ""
echo "════════════════════════════════════════════════════════════════════"
echo "🎉 Pipeline completed successfully!"
echo "════════════════════════════════════════════════════════════════════"
echo ""

echo "Output directory:"
echo "   results/"
echo ""

echo "Key outputs:"
echo ""
echo "✓ Read quality reports     results/fastqc/"
echo "✓ Primer-trimmed reads     results/cutadapt/"
echo "✓ ASV abundance table      results/dada2/ASV_table.tsv"
echo "✓ rRNA screening summary   results/barrnap/"
echo "✓ Contaminant flags        results/decontam/"
echo "✓ MultiQC report           results/multiqc/"
echo "✓ Pipeline run info        results/pipeline_info/"
echo "✓ Overall run summary      results/summary_report/overall_summary.tsv"
echo ""
echo "  NOTE: no taxonomy table is produced today (--skip_taxonomy), and"
echo "  no QIIME2 diversity outputs are produced today (--skip_qiime)."
echo "  See the toggle notes in this script to run those later."
echo ""

echo "Next steps:"
echo ""
echo "1. Open the MultiQC report."
echo "2. Inspect the ASV abundance table."
echo "3. Check the barrnap and decontam summaries — this is where we'll"
echo "   talk about which ASVs look like real 16S signal vs. noise."
echo "4. Continue with the exercises in course/REFERENCE.md"
echo ""
echo "5. To run this on YOUR OWN data, use the reference command shown"
echo "   above, replacing data/samplesheet.csv and data/Metadata.tsv"
echo "   with your real sample sheet and metadata."
echo ""
echo "6. To include taxonomy classification and/or QIIME2 diversity"
echo "   analysis (both skipped above for time), see the --skip_taxonomy"
echo "   and --skip_qiime toggle notes just above the pipeline call"
echo "   in this script."
echo ""

echo "Happy analysing!"
echo ""
