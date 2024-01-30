FROM ghcr.io/ucsd-ets/datascience:stable

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

# 2) change to root to install packages
USER root


RUN apt-get -q update && \
  apt-get -qy install apt-utils  && \
  apt-get -qy dist-upgrade && \
  apt-get -qy auto-remove && \
  apt-get install -qy p7zip-full software-properties-common && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*  && \
  wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O /etc/apt/preferences.d/cuda-repository-pin-600 && \
  apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub  && \
  add-apt-repository \"deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /\"  && \
  apt-get -q update && \
  apt-get install -qqy cuda-11-1 cuda-nvcc-11-1	cuda-toolkit-11-1 && \
  wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libcudnn8_8.0.5.39-1+cuda11.1_amd64.deb -O /var/tmp/libcudnn8.deb  && \
  wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libnccl2_2.8.4-1+cuda11.1_amd64.deb -O /var/tmp/libnccl2.deb  && \
  dpkg -i /var/tmp/libcudnn8.deb /var/tmp/libnccl2.deb  && \
  fix-permissions $CONDA_DIR  && \
  fix-permissions /home/$NB_USER


# apt-get -q update
# apt-get -qy install apt-utils
# apt-get -qy dist-upgrade 
# apt-get -qy auto-remove 
# apt-get install -qy		p7zip-full 		software-properties-common 
# apt-get clean 
# rm -rf /var/lib/apt/lists/*"
# wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin -O /etc/apt/preferences.d/cuda-repository-pin-600 \u0026\u0026 	apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub \u0026\u0026 	add-apt-repository \"deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /\" \u0026\u0026 	apt-get -q update \u0026\u0026 	apt-get install -qqy 		cuda-11-1 		cuda-nvcc-11-1 		cuda-toolkit-11-1 \u0026\u0026 	wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libcudnn8_8.0.5.39-1+cuda11.1_amd64.deb -O /var/tmp/libcudnn8.deb \u0026\u0026 	wget -nv https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/libnccl2_2.8.4-1+cuda11.1_amd64.deb -O /var/tmp/libnccl2.deb \u0026\u0026 	dpkg -i /var/tmp/libcudnn8.deb /var/tmp/libnccl2.deb"
#fix-permissions $CONDA_DIR \u0026\u0026 	fix-permissions /home/$NB_USER"
#/opt/conda/bin/python3 -m pip install --upgrade pip"
#/opt/conda/bin/conda install -y 		jaxlib==0.1.55 		tensorboard"
#pip install torch 		-f https://download.pytorch.org/whl/rocm4.0.1/torch_stable.html \u0026\u0026 	pip install ninja \u0026\u0026 	pip install 'git+https://github.com/pytorch/vision.git@v0.9.0'"
#pip install --no-cache-dir 		torch==1.8.0+cu111 		torchvision==0.9.0+cu111 		torchaudio==0.8.0 		-f https://download.pytorch.org/whl/torch_stable.html"
#pip install --no-cache-dir 		gdown 		imageio-ffmpeg==0.4.3 		jax==0.1.73 		opencv-contrib-python-headless 		opencv-python 		opensimplex 		pillow 		pyspng==0.1.0 		networkx 		scipy"
#(nop)  USER root
#(nop) COPY dir:36a36661fdff68aec2767c0def27d2808864e4eca0678ba1eb7e93151342e0cb in /usr/share/datahub/tests/scipy-ml-notebook "
#chmod -R +x /usr/share/datahub/tests/scipy-ml-notebook \u0026\u0026 	chown -R 1000:100 /home/jovyan \u0026\u0026 	chmod +x /run_jupyter.sh"
#(nop)  USER 1000:100
#(nop)  ENV PATH=/opt/conda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/cuda/bin


COPY env.yaml /tmp/env.yml

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
