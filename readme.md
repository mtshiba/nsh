# nsh
[![Build Status](https://travis-ci.org/gmshiba/nsh.svg?branch=master)](https://travis-ci.org/gmshiba/nsh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![nimble](https://raw.githubusercontent.com/yglukhov/nimble-tag/master/nimble.png)](https://github.com/yglukhov/nimble-tag)

nsh is the **SH**ell implemented on **N**im.
nsh can use not only shell commands, but also Nim code.  
Some shell commands are wrapped or implemanted by Nim,
so you can use nsh instead of Cygwin!


* Commands are implemented in 'nshpkg/unixcmd.nim'.
If you want these procs in other source code, use 'import nshpkg/unixcmd'.

* You can use 'tocl' to export nim variables to shell.

# demo

![demo](demo/nshdemo.gif)

# installation

```
nimble install nsh
```

## Warinig

* When you install nsh by nimble, probably you see this message. It's no problem. Please type 'y' to continue.

```
Prompt: Missing directory C:\pathTo\.nimble\pkgs\nsh-0.x.x\src\nshpkg. Continue? [y/N]
```


* By default, nsh's reaction for nim code is slow since Nim is a compiler language.
It is good to use [TCC](https://bellard.org/tcc/) for the compiler to speed up the reaction, so if you install nsh by nimble, TCC will also be downloaded together.  
But if you are a Windows user, installing tcc is a bit complicated. when install nsh by nimble, TCC will automatically download in current dir. So please move it somewhere and add the path of it.

*Changes: from nsh 0.1.2, install script won't run automatically. please run it yourself.

# Todo

* Implement more commands
* Tab complement
