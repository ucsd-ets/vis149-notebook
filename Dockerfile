# base notebook, contains Jupyter and relevant tools
# See https://urldefense.com/v3/__https://github.com/ucsd-ets/datahub-docker-stack/wiki/Stable-Tag__;!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-zztWoVxF$
# for a list of the most current containers we maintain
#
# datahub-base-notebook:2020.2.9 has Python 3.7.6
ARG     BASE_CONTAINER=ucsdets/datahub-base-notebook:2020.2.9
ARG     CONDA_DIR=/opt/conda
ARG     NB_USER=jovyan

FROM    $BASE_CONTAINER

ENV     NB_GID=100
ENV     PYTHONDONTWRITEBYTECODE 1
ENV     PYTHONUNBUFFERED 1

# change to root to install packages
USER    root

RUN     apt-get -q update && \
        apt-get -qy install apt-utils && \
        apt-get -qy dist-upgrade && \
        apt-get -qy auto-remove && \
        apt-get install -qy \
                p7zip-full \
                software-properties-common && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/*

# CUDA 11
RUN     wget -nv https://urldefense.com/v3/__https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin__;!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-z6xyXVXU$  -O /etc/apt/preferences.d/cuda-repository-pin-600 && \
        apt-key adv --fetch-keys https://urldefense.com/v3/__https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub__;!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-zy96UN_p$  && \
        add-apt-repository "deb https://urldefense.com/v3/__http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/__;!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-z1ptww6x$  /" && \
        apt-get -q update && \
        apt-get install -qqy \
                cuda-11-1 \
                cuda-nvcc-11-1 \
                cuda-toolkit-11-1 && \
        wget -nv https://urldefense.com/v3/__https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libcudnn8_8.0.5.39-1*cuda11.1_amd64.deb__;Kw!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-z23hZqFj$  -O /var/tmp/libcudnn8.deb && \
        wget -nv https://urldefense.com/v3/__https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libnccl2_2.8.4-1*cuda11.1_amd64.deb__;Kw!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-z9s2UILA$  -O /var/tmp/libnccl2.deb && \
        dpkg -i /var/tmp/libcudnn8.deb /var/tmp/libnccl2.deb

RUN     fix-permissions $CONDA_DIR && \
        fix-permissions /home/$NB_USER

# Conda & Pip pkg installs
USER    jovyan

RUN     /opt/conda/bin/python3 -m pip install --upgrade pip

# Tensorboard & jaxlib
RUN     /opt/conda/bin/conda install -y \
                jaxlib==0.1.55 \
                tensorboard

# RocM 4.0.1 (Linux only)
RUN     pip install torch \
                -f https://urldefense.com/v3/__https://download.pytorch.org/whl/rocm4.0.1/torch_stable.html__;!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-zzTLvttR$  && \
        pip install ninja && \
        pip install 'git+https://github.com/pytorch/vision.git@v0.9.0'

# PyTorch
RUN     pip install --no-cache-dir \
                torch==1.8.0+cu111 \
                torchvision==0.9.0+cu111 \
                torchaudio==0.8.0 \
                -f https://urldefense.com/v3/__https://download.pytorch.org/whl/torch_stable.html__;!!Mih3wA!Gdyp1ukt20BXVegNBzmgDfWhJBT9wJRv0kfA_Go0MCt8kLnGgWIlIwf4enXHKWsp-Mfo5Hrl5w5FGlY-zxYAF2xj$

# Other pkgs
RUN     pip install --no-cache-dir \
                gdown \
                imageio-ffmpeg==0.4.3 \
                jax==0.1.73 \
                opencv-contrib-python-headless \
                opencv-python \
                opensimplex \
                pillow \
                pyspng==0.1.0 \
                networkx \
                scipy

# Unset TORCH_CUDA_ARCH_LIST and exec.  This makes pytorch run-time
# extension builds significantly faster as we only compile for the
# currently active GPU configuration.
#RUN (printf '#!/bin/bash\nunset TORCH_CUDA_ARCH_LIST\nexec \"$@\"\n' >> /entry.sh) && chmod a+x /entry.sh
#ENTRYPOINT ["/entry.sh"]

USER    root

COPY    ./tests/ /usr/share/datahub/tests/scipy-ml-notebook
RUN     chmod -R +x /usr/share/datahub/tests/scipy-ml-notebook && \
        chown -R 1000:100 /home/jovyan && \
        chmod +x /run_jupyter.sh

USER    $NB_UID:$NB_GID
ENV     PATH=${PATH}:/usr/local/cuda/bin

# Override command to disable running jupyter notebook at launch
# CMD ["/bin/bash"]
