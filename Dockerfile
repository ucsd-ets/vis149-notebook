FROM ghcr.io/ucsd-ets/datascience-notebook:2023.4-stable

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"
#
# 2) change to root to install packages
USER root



# install cuda toolkit 11-1
# https://developer.nvidia.com/cuda-11.1.0-download-archive?target_os=Linux&target_arch=x86_64&target_distro=Ubuntu&target_version=2004&target_type=debnetwork
RUN apt-get update && \
    apt-get install -y p7zip-full software-properties-common && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
    mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600  && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub  && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub  && \
    add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /etc/apt/sources.list.d/cuda.list && \
    rm -rf /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get update  && \
#apt-get -y install cuda && \
    apt-get install -qqy cuda-11-1 cuda-nvcc-11-1   cuda-toolkit-11-1 && \

    fix-permissions $CONDA_DIR  && \
    fix-permissions /home/$NB_USER


COPY env.yml /tmp/env.yml

RUN conda env create --file /tmp/env.yml && \
    eval "$(conda shell.bash hook)" && \
    conda activate ${KERNEL} && \
    mkdir -p $CONDA_PREFIX/etc/conda/activate.d && \
#    CUDNN_PATH=$(dirname $(python -c "import nvidia.cudnn;print(nvidia.cudnn.__file__)")) && \
#    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CONDA_PREFIX/lib/:$CUDNN_PATH/lib' > $CONDA_PREFIX/etc/conda/activate.d/env_vars.sh && \
    python -m ipykernel install --name=${KERNEL} && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# 3) install packages using notebook user
USER jovyan
# other packages here... 

# From the "original" 2022 version: 
# USER    $NB_UID:$NB_GID
ENV     PATH=${PATH}:/usr/local/cuda/bin



