# Germline WES/WGS Nextflow Pipeline


## 1. Software prerequisites

Before running the pipeline, you need:

* **Nextflow** ≥ 25.04

  * Check with:

    ```bash
    nextflow -version
    ```
* **Docker** (for containerised execution)

  * Check with:

    ```bash
    docker run hello-world
    ```
* **Pulled / build containers**

  * Custom alignment container:

    ```bash
    docker build -t germline-bwa-samtools-biobambam2:0.1 .
    ```
---

## 2. Input data

### 2.1 FASTQ files

Paired-end reads (gzipped) for each sample, e.g.:

```bash
/home/you/project/data/raw/SRR1518158_1.fastq.gz
/home/you/project/data/raw/SRR1518158_2.fastq.gz
/home/you/project/data/raw/SRR1518011_1.fastq.gz
/home/you/project/data/raw/SRR1518011_2.fastq.gz
```

Paths can be anywhere on disk; they are provided via the samplesheet.

### 2.2 Samplesheet (`samplesheet.csv`)


## 3. Reference data

You must:

1. **Download** the GRCh38 FASTA (e.g. from GATK bundle / iGenomes).
2. Place the `.fasta.gz` file where you want (e.g. `data/ref/hsa38/`).
3. Set the correct paths in `nextflow.config` (next section).

The pipeline’s `PREPARE_REF` process will:

* decompress the FASTA into `ref/`
* build a BWA index (`bwa index`) in `ref/`

This happens **once**, then is reused for all samples.

---

## 4. Configuration (`nextflow.config`)

Key parameters you must check/edit:

```groovy
params {
    input        = "${baseDir}/samplesheet.csv"
    outdir       = "${baseDir}/results"

    // compressed reference FASTA
    ref_fasta_gz = "/home/you/data/ref/hsa38/Homo_sapiens_assembly38.fasta.gz"
    // decompressed filename INSIDE ref/
    fasta_name   = "Homo_sapiens_assembly38.fasta"

    igenomes_base = "/home/you/data/ref/igenomes"
    genome        = "GATK.GRCh38"
}

process {

    withLabel: 'prepare_ref' {
        cpus      = 4
        memory    = '8 GB'
        time      = '4h'
        container = 'germline-bwa-samtools-biobambam2:0.1'
    }

    withLabel: 'bwa_mem_markdup' {
        cpus      = 8
        memory    = '24 GB'
        time      = '24h'
        container = 'germline-bwa-samtools-biobambam2:0.1'
    }

    withName: 'FASTQC' {
        container = 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'
    }
}
```

Adjust paths (`ref_fasta_gz`, `input`, `outdir`, `igenomes_base`) to your environment.

---

## 5. How to run

From the pipeline directory:

```bash
cd /path/to/germline-nextflow

# First full run
nextflow run main.nf -profile docker

# Rerun after small code/path changes
nextflow run main.nf -profile docker -resume
```

Outputs (e.g. FastQC reports, BAMs, duplication metrics) will appear under:

test
