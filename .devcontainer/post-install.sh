#!/bin/bash
# post-install.sh
# Runs automatically when the GitHub Codespace is created.
# Installs Nextflow and pre-downloads the nf-core/ampliseq pipeline.

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Ampliseq 16S Training — Codespace Setup                    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

###############################################################################
# Step 1 — Install Nextflow
###############################################################################

echo "Installing Nextflow..."

conda install -y -c bioconda nextflow > /dev/null 2>&1

echo "✓ Nextflow: $(nextflow -version 2>&1 | head -1)"

###############################################################################
# Step 2 — Pre-download nf-core/ampliseq
###############################################################################

echo ""
echo "Downloading nf-core/ampliseq v2.18.0..."

nextflow pull nf-core/ampliseq -r 2.18.0 > /dev/null 2>&1

echo "✓ nf-core/ampliseq v2.18.0 cached"

###############################################################################
# Step 3 — Verify installation
###############################################################################

echo ""
echo "Verifying installation..."

echo "✓ Java: $(java -version 2>&1 | head -1)"
echo "✓ Nextflow: $(nextflow -version 2>&1 | head -1)"

if command -v docker >/dev/null 2>&1; then
    echo "✓ Docker: $(docker --version)"
else
    echo "⚠ Docker is still starting. If 'bash main.sh' fails, wait a few seconds and try again."
fi

###############################################################################
# Finished
###############################################################################

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  ✅ Setup complete!                                         ║"
echo "║                                                              ║"
echo "║  Run the practical with:                                    ║"
echo "║                                                              ║"
echo "║     bash main.sh                                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
