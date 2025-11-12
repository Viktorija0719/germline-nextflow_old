process BWA_MEM_MARKDUP {

    tag "${meta.id}"
    label 'bwa_mem_markdup'

    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
    // 1) Sample meta + reads list
    tuple val(meta), path(reads)

    // 2) Reference directory from PREPARE_REF
    //    We don't need to *use* the variable in the script, but this input
    //    makes Nextflow stage the `ref/` directory and enforces dependency.
    path ref_dir

    output:
    tuple val(meta),
          path("${meta.id}.rmdup.bam"),
          path("${meta.id}.rmdup.bam.bai"),
          path("${meta.id}.rmdup.duplication_metrics.txt")

    script:
    """
    set -euo pipefail

    # PREPARE_REF outputs a directory named 'ref', which Nextflow stages here.
    # We can just use that directory name directly.
    REF="ref/${params.fasta_name}"

    bwa mem -t ${task.cpus} -K 100000000 -Y \\
        -R "@RG\\tID:${meta.id}\\tSM:${meta.id}\\tLB:${meta.id}\\tPU:${meta.id}_1\\tPL:ILLUMINA" \\
        "\$REF" \\
        ${reads[0]} ${reads[1]} \\
      | samtools view -@ ${task.cpus} -b - \\
      | samtools sort -@ ${task.cpus} -o ${meta.id}.sorted.bam -

    bammarkduplicates markthreads=${task.cpus} rmdup=1 \\
        I=${meta.id}.sorted.bam \\
        O=${meta.id}.rmdup.bam \\
        M=${meta.id}.rmdup.duplication_metrics.txt

    samtools index -@ ${task.cpus} ${meta.id}.rmdup.bam
    """
}
