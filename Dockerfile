FROM ghcr.io/ucsd-ets/datascience-notebook:2023.4-stable

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"
#
# 2) change to root to install packages
USER root


RUN     apt-get -q update && \
        apt-get -qy install apt-utils && \
        apt-get -qy dist-upgrade && \
        apt-get -qy auto-remove && \
        apt-get install -qy \
                p7zip-full \
                software-properties-common && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# CUDA 11-1
RUN     wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O /etc/apt/preferences.d/cuda-repository-pin-600 && \
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
        wget https://developer.download.nvidia.com/compute/cuda/repos/$distro/$arch/cuda-keyring_1.0-1_all.deb && \
        dpkg -i cuda-keyring_1.0-1_all.deb && \
        add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" && \
        apt-get -q update && \
        apt-get install -qqy cuda-11-1 cuda-nvcc-11-1	cuda-toolkit-11-1 && \

# install cuda toolkit 
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
    apt-get install -qqy cuda-11-1 cuda-nvcc-11-1 cuda-toolkit-11-1 && \
    
  wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libcudnn8_8.0.5.39-1+cuda11.1_amd64.deb -O /var/tmp/libcudnn8.deb  && \
  wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libnccl2_2.8.4-1+cuda11.1_amd64.deb -O /var/tmp/libnccl2.deb  && \
  dpkg -i /var/tmp/libcudnn8.deb /var/tmp/libnccl2.deb  && \
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


USER    $NB_UID:$NB_GID
ENV     PATH=${PATH}:/usr/local/cuda/bin



