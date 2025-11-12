process PREPARE_REF {

    tag "${ref_fasta_gz.simpleName}"
    label 'prepare_ref'

    // Keep a copy of the prepared reference in results/ref
    publishDir "${params.outdir}/ref", mode: 'copy'

    input:
    // Compressed reference FASTA
    path ref_fasta_gz

    output:
    // Output the whole ref/ directory as a single path object
    path "ref"

    script:
    """
    set -euo pipefail

    mkdir -p ref

    # Remove .gz suffix only
    BASE=\$(basename ${ref_fasta_gz} .gz)

    # 1) Unzip FASTA into ref/
    gunzip -c ${ref_fasta_gz} > ref/\$BASE

    # 2) Build BWA index in ref/
    bwa index ref/\$BASE
    """
}
