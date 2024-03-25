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
- `project_busy_wait`:
    Wait for a project build to finish, and prints the live logs.
    Requires `project_build` first.
- `project_download`:
    Downloads the results of a project build. 
    Requires a finished build first.
- `project_open`:
    Open an exisiting project or creates a new one.
- `project_show`:
    Shows the details of the current project.
- `project_upload_deb`:
    Uploads a Debian binary package to the current active project.
    This makes the package available for image builds.
- `project_wait_and_download`:
    Waits for a project build to finish, and downloads the build results afterwards.
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
    -f Dockerfile_bookworm \
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
- Install the SDK


TODO implement

## CI usage

### Build an image

### Build an application Debian package

## Test the container

TODO Implement automated tests