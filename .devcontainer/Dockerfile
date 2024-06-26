FROM debian:bookworm

ARG USER="dev"

USER root
ENV DEBIAN_FRONTEND noninteractive

RUN apt update

# install build tools, QEMU and Python
RUN apt -y install \
        build-essential make cmake pkg-config crossbuild-essential-arm64 \
        gcc-aarch64-linux-gnu g++-aarch64-linux-gnu gcc g++ gdb-multiarch \
        qemu-system-arm qemu-system-x86 qemu-kvm \
        wget xz-utils locales kmod sudo git vim \
        rsync lshw gdisk fdisk parted file \
        dh-make devscripts pbuilder debootstrap apt-utils \
        tcpdump iputils-ping iproute2 curl \
        python3 python3-pip python3-venv libvirt-dev

# setup locale
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

##### create user #####

ARG HOST_USER=1000
ARG HOST_GROUP=1000

# Create build user mathching outside UID and GID to avoid ownership issues
# and allow user to use sudo
RUN addgroup --gid $HOST_GROUP $USER && \
  useradd -rm -d /home/$USER -s /bin/bash -g $USER -G sudo -u $HOST_USER $USER && \
  echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers && \
  mkdir -p /home/$USER/.ssh && \
  chown -R $USER:$USER /home/$USER && \
  mkdir -p /build/scripts && \
  mkdir -p /build/init && \
  mkdir -p /build/results && \
  mkdir -p /build/identity && \
  chown -R $USER:$USER /build && \
  mkdir -p /workspace && \
  chown -R $USER:$USER /workspace

# Copy bashrc
COPY bashrc /home/$USER/.bashrc
RUN sudo chown $USER:$USER /home/$USER/.bashrc && chmod +x /home/$USER/.bashrc
COPY bashrc /root/.bashrc
RUN sudo chown root:root /root/.bashrc && chmod +x /root/.bashrc

# Add container user to host kvm group
ARG KVM_GID
# Add container user to group with host KVM GID, to allow kvm acceleration
RUN if [ $(getent group $KVM_GID) ]; then \
      usermod -a -G $(getent group $KVM_GID | cut -d: -f1) $USER; \
    else \
      addgroup --gid ${KVM_GID} kvm_host; \
      usermod -a -G kvm_host ${USER}; \
    fi

WORKDIR /build
USER $USER

# Get elbe from Github
# install packages needed by elbe dependencies
RUN sudo apt -y install python3-gpg python3-lxml python3-mako \
    python3-passlib python3-pycdlib python3-debian python3-suds \
    python3-libvirt swig cpio patchelf
# Then clone elbe to 
RUN git clone --depth 1 https://github.com/Linutronix/elbe 

# install packages needed by scripts
RUN sudo apt -y install lsof socat tmux

# reduce container size
RUN sudo apt clean -y
RUN sudo rm -rf /var/lib/apt/lists/*


# Save some build infos
# This also triggers a rebuild of the line belows
ARG CREATE_COMMIT
RUN echo "Commit: $CREATE_COMMIT" > /build/container_info.txt

# Update elbe git repo
RUN bash -c "cd /build/elbe; git fetch; git reset --hard origin/master"

USER root

# Copy pbuilderrc
RUN sudo ln -sf /build/identity/pbuilderrc /home/$USER/.pbuilderrc
RUN sudo ln -sf /build/identity/pbuilderrc /root/.pbuilderrc

# copy Debian repositry keys - needed for initvm setup
COPY repo_keys/* /etc/apt/trusted.gpg.d/

# copy scripts
COPY scripts/* /build/scripts/
RUN chmod +x /build/scripts/*

ARG CREATE_DATE
RUN echo "Date: $CREATE_DATE" >> /build/container_info.txt

WORKDIR /workspace
USER $USER

CMD "bash"
