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
nimble install https://githib.com/gmshiba/nsh
```

## Warinig

* When you install nsh by nimble, probably you see this message. It's no problem. Please type 'y' to continue.

```
Prompt: Missing directory C:\pathTo\.nimble\pkgs\nsh-0.x.x\src\nshpkg. Continue? [y/N]
```

* By default, nsh's reaction for nim code is slow since Nim is a compiler language.
It is good to use [TCC](https://bellard.org/tcc/) for the compiler to speed up the reaction. So I recommend to install it. You can use ':tcc on' to use TCC for compiler.


# Todo

* Implement more commands
* Tab complement

# Available commands list

| Command Name | Proc Name | Can receive value |
| :----------- | --------: | :---------------: |
| pwd          |       pwd |         ×         |
| cd           |        cd |         ×         |
| rm           |        rm |         ×         |
| ls           |        ls |         ×         |
| mkdir        |     mkdir |         ×         |
| rmdir        |     rmdir |         ×         |
| cp           |        cp |         ×         |
| mv           |        mv |         ×         |
| pushd        |     pushd |         ×         |
| popd         |      popd |         ×         |
| cat          |       cat |         ×         |
| touch        |     touch |         ×         |
| file         |      file |         ×         |
| find         |     ffind |         ×         |
| locate       |    locate |         ×         |
| more         |      more |         ×         |
| less         |      less |         ×         |
| head         |      head |         ×         |
| tail         |      tail |         ×         |
| grep         |      grep |         ○         |
| wc           |        wc |         ○         |
| sed          |       sed |         ○         |
| tee          |       tee |         ○         |
| join         |     fjoin |         ×         |
| diff         |      diff |         ×         |
| cut          |       cut |         ×         |
| uniq         |      uniq |         ×         |
| sort         |      sort |         ×         |
| nkf          |       nkf |         ×         |
| history      |   history |         ×         |
| ps           |        ps |         ×         |
| kill         |      kill |         ×         |
| lp           |        lp |         ×         |
| lpstat       |    lpstat |         ×         |
| cancel       |    cancel |         ×         |
| du           |        du |         ×         |
| ln           |        ln |         ×         |
| man          |       man |         ×         |
| which        |     which |         ×         |
| tar          |       tar |         ×         |
| id           |        id |         ×         |
| shutdown     |  shutdown |         ×         |
| reboot       |    reboot |         ×         |
| hostname     |  hostname |         ×         |
| groups       |    groups |         ×         |
| chown        |     chown |         ×         |
| chgrp        |     chgrp |         ×         |
| who          |       who |         ×         |
| whoami       |    whoami |         ×         |
| set          |      vset |         ×         |
| printenv     |  printenv |         ×         |
| watch        |     watch |         ×         |
| date         |      date |         ×         |
| sleep        |     sleep |         ×         |
| time         |      time |         ×         |
| xargs        |     xargs |         ×         |
