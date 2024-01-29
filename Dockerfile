# 1) choose base container
# generally use the most recent tag

# base notebook, contains Jupyter and relevant tools
# See https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag 
# for a list of the most current containers we maintain
ARG BASE_CONTAINER=ghcr.io/ucsd-ets/scipy-ml-notebook:stable

FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root

#RUN apt-get -y install htop

#RUN conda env create --file /tmp/env.yml && \
#    eval "$(conda shell.bash hook)" && \
#    conda activate ${KERNEL} && \
#    mkdir -p $CONDA_PREFIX/etc/conda/activate.d && \
#    CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)")) && \
#    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/:$CUDNN_PATH/lib' > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh && \
#    python -m ipykernel install --name=${KERNEL} && \
#    fix-permissions $CONDA_DIR && \
#    fix-permissions /home/$NB_USER

# 3) install packages using notebook user
USER jovyan

# RUN conda install -y scikit-learn

RUN pip install --no-cache-dir networkx scipy

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
