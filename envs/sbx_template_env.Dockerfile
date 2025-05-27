FROM condaforge/mambaforge:latest

# Setup
WORKDIR /home/sbx_snippy_env

COPY envs/sbx_snippy_env.yml ./

# Install environment
RUN conda env create --file sbx_snippy_env.yml --name sbx_snippy

ENV PATH="/opt/conda/envs/sbx_snippy/bin/:${PATH}"

# "Activate" the environment
SHELL ["conda", "run", "-n", "sbx_snippy", "/bin/bash", "-c"]

# Run
CMD "bash"