import pandas
import os

def summarize_snippy(snp_file: str) -> pandas.DataFrame:
    """Return a dataframe for SNPs in each sample"""
    sample = os.path.basename(os.path.dirname(snp_file))
    s = pandas.read_csv(snp_file, sep='\t')
    s.insert(0, "Sample", sample)
    return s

summary_list = [summarize_snippy(s) for s in snakemake.input]
_reports = pandas.concat(summary_list)
_reports.to_csv(snakemake.output[0], sep="\t", index=False)
