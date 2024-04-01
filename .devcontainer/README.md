# Elbe Docker container

You can use this container as stand-alone elbe setup, without using the VS Code dev container.

Structure of the Docker container:

- `repo_keys`: 
    The supported apt repository keys.
    The script `repo_keys/get_keys.sh` extracts the apt repository keys for Debian Bookworm and Ubuntu Jammy form the Docker containers.
- `scripts`: 
    The helper scripts available in the container.
- `bashrc`:
    Bashrc file for the container user.
    The bashrc also sources the `scripts/env.sh`.

Scripts in the container:

- `build_image`:   
    Build an elbe image description using the _elbe initvm submit_ command.
    The result is written to _/build/results/images_.
- `build_image_fast`:   
    Run `build_image`, but skip building of the sources and binaries ISOs.
- `build_image_sdk`:
    Run `build_image`, but also build the Yocto-like SDK.
- `elbe_delete_all_projects`: Maintenance script to delete all projects on the initvm.
- `elbe_qinit`:
    Wrapper for `elbe initvm $@ --directory=/build/init/vm --qemu`.
    In the container, only elbe QEMU mode is supported, and by default the initvm is located at _/build/init/vm_.
    This script shortens the usage the _elbe initvm_ commands.
- `elbe_setup`:
    Prepares the initvm.
    If no initvm is avaliable in _/build/init/vm_, it will run a build of the initvm and start it afterwards.
    If a initvm is available in  _/build/init/vm_, it will start the initvm if it is not already running.
- `elbe_stop`:
    Stop the QEMU initvm.
- `env.sh`:
    Setup the work environment.
    It adds the required folders to PATH and enabled the Python venv for elbe.
- `gen_sign_key`:
    Generate a GPG key for apt repository metadata signing.
- `initvm_ok`:
    Quick check if the initvm is running.
- `overlay_mount`: 
    Mounts and RW overlay for the given folder.
    This is used to allow RO mounting of the image descriptions.
- `project_build`:
    Build the image of a project.
    Requires `project_open` first.
- `project_build_app`:
    Compile a cmake application for the image of the current project.
    Requires `project_open` and an installed SDK first.
- `project_build_sdk`:
    Build a Yocto-like SDK for the image of the current selected project.
    Requires `project_open` first.
- `project_busy_wait`:
    Wait for a project build to finish, and prints the live logs.
    Requires `project_build` first.
- `project_clean`:
    Delete the build results and the elbe initvm project of the current open project.
    Requires `project_open` first.
- `project_download`:
    Downloads the results of a project build. 
    Requires a finished build first.
- `project_install_sdk`:
    Install the Yocto-style SDK of the current open project.
    Requires `project_build_sdk` first.
- `project_open`:
    Open an exisiting project or creates a new one.
- `project_show`:
    Shows the details of the current project.
- `project_upload_deb`:
    Uploads a Debian binary package to the current active project.
    This makes the package available for image builds.
- `project_wait_and_download`:
    Waits for a project build to finish, and downloads the build results afterwards.
- `qemu_aarch64`:
    Run a image using QEMU aarch64.
    This command expects that a kernel binary called _vmlinuz_ and a initrd image called _initrd.img_ is located next to the image.
- `qemu_efi_aarch64`:
    Run a image using QEMU aarch64.
    This command expects that the image contains and EFI partition and an EFI bootloader.
- `qemu_efi_x86_64`:
    Run a image using QEMU x86_64.
    This command expects that the image contains and EFI partition and an EFI bootloader.
- `qemu_x86_64`:
    Run a image using QEMU x86_64.
    This command expects that a kernel binary called _vmlinuz_ and a initrd image called _initrd.img_ is located next to the image.
- `repo`:
    Prepare apt repository metadata and serve the repository.
    This command is a combination of `repo_meta` and `repo_serve`.
    This requires a valid private GPG key to serve the metadata.
- `repo_meta`:
    Prepare apt repository metadata.
    This requires a valid private GPG key to serve the metadata.
- `repo_serve`:
    Prepare apt repository metadata.
    This will fail if already a repository is served.
- `repo_stop`:
    Stops the apt repository server if it is running.

## Build the container

For stand-alone usage, build the Debian Bookworm container with:

```bash
docker build \
    -f Dockerfile \
    --build-arg CREATE_DATE="$(date)" \
    --build-arg CREATE_COMMIT="$(git rev-parse HEAD)" \
    --build-arg HOST_USER="${UID}" \
    --build-arg HOST_GROUP="${GID}" \
    --build-arg KVM_GID="$(getent group kvm  | cut -d: -f3)" \
    -t elbe_bookworm:testing .
```

## Use the container

This readme assumes that you don't perstist the full container but you may want to persist the initvm and build results.

Run the container for stand-alone usage:

```bash
docker run --rm -it \
    -v ${HOME}/.ssh:/home/dev/.ssh:ro \
    -v ${PWD}/../identity:/build/identity:ro \
    -v ${PWD}/../buildenv:/build/init:rw \
    -v ${PWD}/../results:/build/results:rw \
    -v ${PWD}/../images:/images:ro \
    --privileged \
    elbe_bookworm:testing
```

The path _${HOME}/.ssh_ is bind-mounted to make the SSH keys of the user available in the container. This is e.g. needed for git authentication.
The other bind-mounted paths are the folder also used by the VS Code dev container.
The folders _identity_ and _images_ are mounted read-only, to avoid unintended modifications.

To build an image in the container use the following steps:

- `elbe_setup`: This will create the elbe initvm if needed, or start it if it exists.
- `overlay_mount /images`: Mount the RO images folder with a writable overlay to _/tmp/images_.
- `build_image_fast /tmp/images/qemu/systemd/bookworm-aarch4-qemu.xml`: Build the image (without ISO images), and write the result to _/build/results/images/_
- `elbe_stop`: Stop the QEMU initvm.

## Project commands

Run the container for stand-alone usage:

```bash
docker run --rm -it \
    -v ${HOME}/.ssh:/home/dev/.ssh:ro \
    -v ${PWD}/../identity:/build/identity:ro \
    -v ${PWD}/../buildenv:/build/init:rw \
    -v ${PWD}/../results:/build/results:rw \
    -v ${PWD}/../images:/images:ro \
    --privileged \
    elbe_bookworm:testing
```

and run the initvm: `elbe_setup`.
Now you can use the _project_ commands.

### Build an image with a custom Debian package

- Create the project: `project_open /images/qemu/systemd/bookworm-aarch4-qemu.xml`
- Get the binary package: `wget http://archive.ubuntu.com/ubuntu/pool/main/f/file/file_5.32-2_amd64.deb`
- Upload the package: `project_upload_deb ./file_5.32-2_amd64.deb`
- Build the project: `project_build`
- Wait for the build and download the results: `project_wait_and_download`

## Local apt repository

The container supports to server packages as local apt repository.
 
### Signing key

Before you can create a repository, you need a key for signing the metadata.
You can bring your own GnuPG home directory, in folder _/build/identity/.gnupg_,
or you use the container to create a new key.

To create a key, run the container with writable identity folder:

```bash
docker run --rm -it \
    -v ${PWD}/../identity:/build/identity:rw \
    elbe_bookworm:testing
```

Then, create the signing key with `gen_sign_key`.
This command makes use of the Debian maintainer data provided in `identity/maintainer.sh`.

### Apt repository

Now, you can re-run the container with read-only identity folder, to protect your key against unwanted modification:

```bash
docker run --rm -it \
    -v ${HOME}/.ssh:/home/dev/.ssh:ro \
    -v ${PWD}/../identity:/build/identity:ro \
    -v ${PWD}/../buildenv:/build/init:rw \
    -v ${PWD}/../results:/build/results:rw \
    -v ${PWD}/..:/workspace:ro \
    --privileged \
    elbe_bookworm:testing
```

Create a local apt repository with the following steps:

- Mount a writeable overlay over the apt folder: `overlay_mount /workspace/apt/`
- Change to the folder containing the Debian packages: `cd /tmp/workspace/apt`
- Get additional packages if needed: `wget http://archive.ubuntu.com/ubuntu/pool/main/f/file/file_5.32-2_amd64.deb`
- Create the apt repository metadata: `repo_meta .`
- Serve the repository: `repo_serve`
  You can stop the server using the `repo_stop` command.

Now you can use the repositry.
The repositry was also configured for the container apt setup.

The `repo` command automatically does the steps above, except adding additional packages.

### Use the repository in images

Elbe provides two mechanisms to include local images.
You can directly add the repository as url using:

```xml
<url>
    <binary>http://LOCALMACHINE:8000 local main</binary>
    <source>http://LOCALMACHINE:8000 local main</source>
    <raw-key>
        ASCII-ARMORED SIGNING KEY
    </raw-key>
</url>
```

Please replace _ASCII-ARMORED SIGNING KEY_ with the content of _dists/local/Release.asc_ in your repository folder. Elbe will automatically take care of replacing _LOCALMACHINE_ with the right IP address.

You can shorten this by using the _repodir_ tag:

```xml
<repodir signed-by="dists/local/Release.asc">REPO_FOLDER local main</repodir>
```

Please replace *REPO_FOLDER* with the path to your apt repository in the container. Elbe will also auto-serve this repository when preprocessing the image XML.

## Build and package applications

For developing and testing and application, the best approach is to use the cross-compile toolchain (SDK), and test the result in the binary image.

The folling steps need to be executed in the container. Run the container:

```bash
docker run --rm -it \
    -v ${HOME}/.ssh:/home/dev/.ssh:ro \
    -v ${PWD}/../identity:/build/identity:ro \
    -v ${PWD}/../buildenv:/build/init:rw \
    -v ${PWD}/../results:/build/results:rw \
    -v ${PWD}/../sdks:/build/sdks:rw \
    -v ${PWD}/..:/workspace:ro \
    --name elbe_bookworm \
    --privileged \
    elbe_bookworm:testing
```

Naming the container allows you to open a second shell using:

```bash
docker exec -it elbe_bookworm bash
```

### Prepare the image and the SDK

- Open the project: `project_open /workspace/images/qemu/systemd/bookworm-aarch4-qemu.xml`
- Build the image: `project_build`
- Wait for the build to finish and download the results: `project_wait_and_download`
- Build the SDK: `project_build_sdk`
- Wait for the build to finish and download the results: `project_wait_and_download`
- Install the SDK: `project_install_sdk`

### Build the app

- Open the project: `project_open /workspace/images/qemu/systemd/bookworm-aarch4-qemu.xml`
- Build the app: `project_build_app`

### Test the app

- Open a tmux session: `tmux`
- Run the image: `qemu_aarch64 /build/results/images/bookworm-aarch4-qemu/sdcard.qcow2`
- Detach from the tmux session: _CTRL + B, D_
- Alternative: Open a second shell in the container (`docker exec -it elbe_bookworm bash`) and run QEMU in this shell.
- Check ssh is working: `ssh -p 2222 root@127.0.0.1` and disconnect using `exit`
- Close and copy the app using scp: `scp -P 2222 /build/results/apps/cmake-minimal/MyJsonApp root@127.0.0.1:/tmp`
- Attach to tmux (or switch to the second shell): `tmux attach`
- Run the app: `/tmp/MyJsonApp`

If you want to do remote debugging, you can use gdbserver.

- Run gdbserver: `gdbserver localhost:4444 /tmp/MyJsonApp`
- Detach from the tmux session: _CTRL + B, D_
- Run gdb: `gdb-multiarch /build/results/apps/cmake-minimal/MyJsonApp`
- Connect to the gdbserver: `target remote :4444`

Debug the app:

- Set breakpoint at main: `break main`
- Continue the execution: `c`
- Single step debugging: `si`
- Continue execution: `c`

Shutdown QEMU:

- Attach to tmux: `tmux attach`
- Poweroff the VM: `systemctl poweroff`
- Exit tmux: `exit`

### Package the app using pbuilder

- Prepare the pbuilder environment: `sudo pbuilder create`

This create a base environment for the distribution and mirror specified in `identity/pbuilderrc`. If you don't want to build for Debian Bookworm, please update the file.

- Prepare the app package: `package_prepare /workspace/apps/cmake-minimal/ my-app 1.0.0`
- Make sure that _cmake_, _pkg-config_, and _libjsoncpp-dev_ is added as build-time dependency.
- Change to the app folder: `cd /build/results/packages/my-app-1.0.0`
- Build the package for x86_64: `pdebuild`
- Build the package for aarch64: `pdebuild -- --host-arch arm64`

For more details about Debian packaging, take a look at the Debian maintainers guide:
https://www.debian.org/doc/manuals/maint-guide/

### Add the package to the image

- Create apt repository metadata: `repo /build/results/packages`
- Add the local repo to the mirrors file _images/includes/bookworm_mirrors.xml_ as described in the _repo_ output.
- Add the package to to the image description _images/qemu/systemd/bookworm-aarch4-qemu.xml_.
- Build the image:
```bash
project_open /workspace/images/qemu/systemd/bookworm-aarch4-qemu.xml
project_build
project_wait_and_download
```
- Run the image: `qemu_aarch64 /build/results/images/bookworm-aarch4-qemu/sdcard.qcow2`
- Login and run the app: `MyJsonApp`

## CI usage

You can use the container to build images and app packages full-automated in a CI environment.

### Build an image

- *CI_IMAGE_REPO*:
    Url of the git repository containing the image description.
- *CI_GIT_PARAMS*:
    Parameters for the git clone command.
- *CI_IMAGE_DESCRIPTION*:
    Path to the image description XML in the git repo.
- *CI_MIRROR_CONF*:
    Url to a repository configuration XML include file.
    This file will be downloaded to the subfolder _includes_ in the root folder of the repository.
    To make use of it, the image description needs to reference this file.
- *CI_IMAGE_VARIANT*:
    Additional paramters given to elbe. This can be used to e.g. build an image variant.

```bash
mkdir results
docker run --rm -it \
    -v ${HOME}/.ssh:/home/dev/.ssh:ro \
    -v ${PWD}/../buildenv:/build/init:rw \
    -v ${PWD}/results:/build/results:rw \
    -e "CI_IMAGE_REPO=https://github.com/tomirgang/elbe_images.git" \
    -e "CI_GIT_PARAMS=-b main" \
    -e "CI_IMAGE_DESCRIPTION=qemu/systemd/bookworm-aarch4-qemu.xml" \
    -e "CI_MIRROR_CONF=https://raw.githubusercontent.com/tomirgang/elbe_images/main/includes/bookworm_mirrors.xml" \
    -e "CI_ELBE_PARAMS=--variant debug --skip-build-bin --skip-build-sources" \
    --privileged \
    elbe_bookworm:testing /build/scripts/ci_image
```

### Build an application Debian package

- *CI_APP_REPO*:
    Url of the git repository containing the app.
    The repo must also contain the Debian metadata.
- *CI_GIT_PARAMS*:
    Parameters for the git clone command.
- *CI_APP_PATH*:
    Path to the app in the git repo.
- *CI_PBUILDERRC*:
    Url to a pbuilderrc file.
    This file will be downloaded and provided to the pbuilder commands.

```bash
mkdir results
docker run --rm -it \
    -v ${HOME}/.ssh:/home/dev/.ssh:ro \
    -v ${PWD}/results:/build/results:rw \
    -e "CI_APP_REPO=https://github.com/tomirgang/example_apps.git" \
    -e "CI_GIT_PARAMS=-b debianize" \
    -e "CI_APP_PATH=cmake-minimal" \
    -e "CI_PBUILDERRC=https://raw.githubusercontent.com/tomirgang/elbe_dev_container/main/identity/pbuilderrc" \
    --privileged \
    elbe_bookworm:testing /build/scripts/ci_package
```
