# Elbe Dev Container

Elbe-rfs Docker container and VS Code dev container workspace.

## Content

The workspace is structured in the following way:

- The folder _app_ contains example applications.
- The folder _images_ contains example image descriptions.
- The folder _result_ will be used for build results.
    - The subfolder _result/apps_ will contain app and package build results
    - The subfolder _result/images_ will contain image build results
- The folder _sdks_ will be used for installing cross-compile toolchains.
- The folder _scripts_ can contain additional workspace specific scripts.

The other folders are special folder:

- The folder _.devcontainer_ contains the VS Code [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers) specification.
- The folder _.vscode_ contains the VS Code configuration, e.g. the available build tasks in _.vscode/tasks.json_.
- The folder _buildenv_ contains the elbe _initvm_.

## Usage

The workspace can be used as VS Code dev containers workspace.
For details how to setup this environment, please take a look at https://code.visualstudio.com/docs/devcontainers/containers.

If you want to use only the Docker container, take a look at `.devcontainer/README.md`.

### Setup

#### Windows

You can use this workspace on Windows using WSL2, Virtual Box or Docker Desktop.
In any case, you need to enable nested virtualization, to allow running KVM accelerated VMs in the container. This is necessary to provide reasonable build speeds.

You need to disable the Windows Hypervisor to be able to use kvm support.
To do this, open PowerShell as administrator and run the following command:

```shell
bcdedit /set hypervisorlaunchtype off
```

Then reboot your Windows.

After the reboot you can enable the nested virtualization support for your VM.

For virtual box, you do this by opening the VM settings, and go to _System_ and _Processor_ and check the _Enabled Nested VT-x/AMD-V_ checkbox.

For WSL2, take a look at https://learn.microsoft.com/en-us/windows/wsl/faq.

#### Ubuntu

On Ubuntu, you can use the _kvm-ok_ command to check if KVM virtualization is enabled on your machine. If the command is not available you can install it by installing the _cpu-checker_ package.

For more details, take a look at https://ubuntu.com/blog/kvm-hyphervisor or
https://www.linuxtechi.com/how-to-install-kvm-on-ubuntu-22-04/

### Build images

#### Setup image build environment

For building images, you first need to setup the elbe _initvm_.

This workspace should do this full automated, using the _scripts/poststart.sh_ script. This script first starts the _libvirtd_ service, which is used for running the VM, and afterwards uses elbe to run, or create, the _initvm_.

Building the _initvm_ may take more than 30 minutes, depending on your machine, but this is typically a one time setup activity.

For more detaails about [elbe](https://elbe-rfs.org/) and the [initvm](https://elbe-rfs.org/docs/sphinx/elbe-initvm.html) you can take a look at the elbe documentation.

#### Solving initvm issues

This workspace, and the used container, provide some more helper scirpts. These scrips may help you in case of errors.

First of all, you can re-bootstrap the VS Code devcontainer, and get the latest base Docker container by opening the command prompt using _<CTRL> + <SHIFT> + <P>_ and running _Dev Containers: Rebuild Container without Cache_.

If this doesn't help, you can make use of the _scripts/delete_initvm.sh_ and then reopen the workspace, to trigger a fresh _initvm_ build.

Their are some more scripts:

- _start_libvirtd.sh_ starts the libvird. This will cause trouble if libvirtd is already running.
- _start_initvm.sh_  starts the initvm.
- _create_initvm.sh_ will build a fresh _initvm_. This build will fail if the _initvm_ already exists.

#### Build an image

This workspace makes use of [elbe](https://elbe-rfs.org/) for image building.

By opening a terminal, you can manually run elbe commands, but the SDK
also provides some helper scripts to make image building very easy:

- _build_image.sh_ "path to the image": Default image build. The results are written to _result/images_.
- _build_image_no_iso.sh_ "path to the image": Fast image build, by skipping generation of ISO images. The results are written to _result/images_.
- _build_image_sdk.sh_ "path to the image": Full image build, also building the stand-alone cross-compile toolchain. The results are written to _result/images_.

All the "path to image" parameters can be relative to the current location in a shell, relative inside the _images_ folder of the workspace, or abosulte in the SDK container.

### Use an image

### Run the image using QEMU

### Flash the image to an SD card

### Customize the image

#### Add custom Debian packages

### Application development

#### Use a cross-compile toolchain

#### Test an application binary using QEMU and SSH

##### Debug an application using remote GDB

### Package applications

#### Debianize the application

#### Build the application package

#### Add the new package to an image description

## CI usage

### Build an image

### Build an application Debian package
