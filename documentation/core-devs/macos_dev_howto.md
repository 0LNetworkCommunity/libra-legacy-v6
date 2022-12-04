# Prerequisite
You need the following tools to develop on macOS and compile and link the binaries:
* [XCode Command Line Tools](https://developer.apple.com/library/archive/technotes/tn2339/_index.html). You can either install XCode from the App Store or use the link to get more information on how to install the command line tools. These tools add support for `git`, `make` and other tools
* an installer that allows to install the missing Unix libraries and tools for macOS. This tutorial assumes you are using [Homebrew](https://brew.sh/), a package manager for macOS. You can find an easy way to install Homebrew on their website (see link above). 

Last but not least you need to export the path where your package manager installs the Unix libraries, so that the linker (`cc`) can find them:

* if you use zsh (the default shell on macOS starting with Catalina) the file to place this export is the `.zprofile` file in your home directory:
```
$ echo "export LIBRARY_PATH=$(brew --prefix)/lib" >> ~/.zprofile
$ source ~/.zprofile
```
* if you use bash, the `.bash_profile` file in your home directory is the relevant file:
```
$ echo "export LIBRARY_PATH=$(brew --prefix)/lib" >> ~/.bash_profile
$ source ~/.bash_profile
```

# Getting the source code
For all the following commands you need to open the Terminal app.

1. Clone the libra source into a local folder of your choice (denoted as `<<your project folder>>` in the following statements)
```
$ cd <<your project folder>>
$ git clone git@github.com:OLSF/libra.git
```
2. Install the Rust programming language and some tools.
```
$ cd libra
$ chmod +x ./ol/util/setup.sh
$ ./ol/util/setup.sh | bash
$ source ~/.profile
```
The last command ensures that the newly created `cargo` tool is available for you to run. If you don't want to execute this line every time you open a terminal you need to put the contents of this file into your `.zprofile`/`.bash_profile` file.
3. Install some additional libraries via `brew`.
```
$ brew update
$ brew install coreutils gmp michaeleisel/zld/zld
```
4. Run the build process
```
$ make bins install
```
The build process should end with a question whether the path where the binaries are eventually placed should be put on your path. If you answer with no, you can run the tools by prefixing the command with the folder, e.g.:
```
$ ~/bin/tower
```

Your environment is now set up, and you can start building and running the applications locally.

# Test Environments
The documentation above has been successfully tested on an Apple Silicon M1 MacBook Pro running macOS Monterey.
