# Elbe Docker container

You can use this container as stand-alone elbe setup, without using the VS Code dev container.

Structure of the Docker container:

- `repo_keys`: The supported apt repository keys.
               The script `repo_keys/get_keys.sh` extracts the apt repository keys for Debian Bookworm and Ubuntu Jammy form the Docker containers.
-  `scripts`:  The helper scripts available in the container.
- `bashrc`:    Bashrc file for the container user.
               The bashrc also sources the `scripts/env.sh`.

## Build the container

For stand-alone usage, build the Ubuntu 22.04 (Jammy) container with:

```bash
docker build -f Dockerfile_jammy -t elbe_jammy:testing .
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
    --privileged \
    elbe_jammy:testing
```



## Test the container

