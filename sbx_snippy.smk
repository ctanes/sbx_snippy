def get_template_path() -> Path:
    for fp in sys.path:
        if fp.split("/")[-1] == "sbx_snippy":
            return Path(fp)
    raise Error(
        "Filepath for sbx_snippy not found, are you sure it's installed under extensions/sbx_snippy?"
    )

ISOLATE_FP = Cfg["all"]["output_fp"] / "isolate"
SBX_TEMPLATE_VERSION = open(get_template_path() / "VERSION").read().strip()

try:
    BENCHMARK_FP
except NameError:
    BENCHMARK_FP = output_subdir(Cfg, "benchmarks")
try:
    LOG_FP
except NameError:
    LOG_FP = output_subdir(Cfg, "logs")


localrules:
    all_snippy,


rule all_snippy:
    input:
        ISOLATE_FP / "reports" / "snippy.txt"
        #expand(ISOLATE_FP / "snippy" / "{sample}" / "snps.tab", sample=Samples)

rule snippy_report:
    """Combine snippy outputs in one file"""
    input:
        expand(ISOLATE_FP / "snippy" / "{sample}" / "snps.tab", sample=Samples),
    output:
        ISOLATE_FP / "reports" / "snippy.txt",
    log:
        LOG_FP / "snippy_report.log",
    benchmark:
        BENCHMARK_FP / "snippy_report.tsv"
    #container:
    #    f"docker://sunbeamlabs/sbx_snippy:{SBX_TEMPLATE_VERSION}"
    script:
        "scripts/snippy_report.py"

rule sga_snippy:
    """Run snippy against a reference genome"""
    input:
        rp1=QC_FP / "decontam" / "{sample}_1.fastq.gz",
        rp2=QC_FP / "decontam" / "{sample}_2.fastq.gz",
    output:
        ISOLATE_FP / "snippy" / "{sample}" / "snps.tab",
    log:
        LOG_FP / "sga_snippy_{sample}.log",
    params:
        reference=Cfg["sbx_snippy"]["reference_fp"],
        out_dir = str(ISOLATE_FP / "snippy" / "{sample}"),
        min_reads=Cfg["sbx_snippy"]["min_reads"] 
    benchmark:
        BENCHMARK_FP / "sga_snippy_{sample}.tsv"
    conda:
        "envs/sbx_snippy_env.yml"
    #container:
    #    f"docker://sunbeamlabs/sbx_snippy:{SBX_TEMPLATE_VERSION}"
    shell:
        """
        if [ $(zgrep -c "^@" {input.rp1}) -gt {params.min_reads} ]; then
            snippy --force --reference {params.reference} --R1 {input.rp1} --R2 {input.rp2} --outdir {params.out_dir} &> {log};
        else
            echo -e "CHROM\tPOS\tTYPE\tREF\tALT\tEVIDENCE\tFTYPE\tSTRAND\tNT_POS\tAA_POS\tEFFECT\tLOCUS_TAG\tGENE\tPRODUCT" > {output}
        fi
        """
