# opt
Inspired by [How I Do](http://brettviren.github.io/howido.html), I decided to formalize my setup... the applications and configuration I do on top of the base system.  The idea is to unpack a tarball and then run `init.sh` and my computer will configure itself approximately how I like.  For work, I only use debian and ubuntu, so this is only designed to work on these platforms.  The flow is something like this:
* `init.sh` 
  - Figures out which distro is running and if it's debian it adds `contrib`, `non-free` components to the sources and the `*-backport` suite.
  - Installs the pre-dependencies needed to run the Makefile.
  - Runs `make base-system`, `make install-dependencies` and `make`.
* `make base-system`
  - Creates a meta-package `task-base` with all currently installed packages as dependencies.
  - `task-base` is installed.
  - All other manual packages are marked auto.
* `make install-dependencies`
  - Visits all subtargets collecting dependencies to install from the repos and elsewhere.
  - Adds these as dependencies of a meta-package `task-opt`.
  - `task-opt` is installed w/ these dependencies.
  - All dependencies marked manual are marked auto.
  - `make sudo-configure` is run to allow subtargets to the system (things like adding the current user to the `docker` group).
* `make`
  - `make dependencies` runs which checks if all dependencies are installed and if not runs `make install-dependencies`
  - `make install` visits each subtarget and runs the `install` goal
  - `make post-configure` allows subtargets to configure their software.
## deploy.tar
The tarball that conveys this mechanism is also built by the makefile.  It includes everything needed to run the makefile as well as configuration for things like `ssh` and `gnupg` (i.e., "secrets") and configuration managed by [vcsh](https://github.com/RichiH/vcsh).
## test
To test this process, the makefile can build docker images for both debian and ubuntu which it runs `init.sh` inside.
## task-base and task-opt
The meta-packages are meant to help organize the system.  When `task-opt` and its dependencies are uninstalled, the system is returned to its "base" state.  To add/remove new packages to `task-opt`, they simply needed to be added/removed to/from one of the subtargets.  `apt-packages` is provided for packages that fulfill no dependency of another subtarget.
To add a package to `task-base` simply install it normally and run `make base-system`.  For removal, `opt/bin/opt-base-remove` is provided.  The idea is that things like drivers or the desktop environment can be added to `task-base`, these are things specific to the system, while `task-opt` is specific to the user.
Packages installed outside these meta-packages will show up in `apt-mark showmanual`.  This way they can easily be uninstalled if they are not useful or added to `task-base` or `task-opt` as appropriate.
