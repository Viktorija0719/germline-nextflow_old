nextflow.enable.dsl = 2

include { FASTQC }         from './modules/nf-core/fastqc/main.nf'
include { PREPARE_REF     } from './modules/local/prepare_ref.nf'
include { BWA_MEM_MARKDUP } from './modules/local/bwa_mem_markdup.nf'


workflow {

    // FASTQC
    reads_fastqc_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            def meta = [ id: row.sample, patient: row.patient, lane: row.lane ]
            tuple(meta, file(row.fastq_1), file(row.fastq_2))
        }

    fastqc_input  = reads_fastqc_ch.map { meta, r1, r2 -> tuple(meta, [r1, r2]) }
    fastqc_output = FASTQC(fastqc_input)

    // BWA reads (can be a clone; reading twice is fine for now)
    reads_bwa_ch = Channel
        .fromPath(params.input)
        .splitCsv(header: true)
        .map { row ->
            def meta = [ id: row.sample, patient: row.patient, lane: row.lane ]
            tuple(meta, file(row.fastq_1), file(row.fastq_2))
        }

    // Reference
    ref_fasta_ch = Channel.of( file(params.ref_fasta_gz) )
    ref_dir_ch   = PREPARE_REF(ref_fasta_ch)

    // (meta, r1, r2) -> (meta, [r1, r2])
    bwa_reads = reads_bwa_ch.map { meta, r1, r2 -> tuple(meta, [r1, r2]) }

    // IMPORTANT: two separate channels, no `.combine()` anymore
    aligned_bams = BWA_MEM_MARKDUP(bwa_reads, ref_dir_ch)

    aligned_bams.view { meta, bam, bai, dup_metrics ->
        "Aligned sample ${meta.id} -> BAM: ${bam}, BAI: ${bai}, METRICS: ${dup_metrics}"
    }
}
