# nish

nish is the **SH**ell implemented on **NI**m.
nish can use not only shell commands, but also Nim code.  
Some shell commands are wrapped or implemanted by Nim,
so you can use nish instead of Cygwin!


* Commands are implemented in 'nishpkg/unixcmd.nim'.
If you want these procs in other source code, use 'import nishpkg/unixcmd'.

# demo

![demo](demo/nishdemo.gif)

## Warinig

* When you install nish by nimble, probably you see this message. It's no problem. Please type 'y' to continue.

```
Prompt: Missing directory C:\pathTo\.nimble\pkgs\nish-0.x.x\src\nishpkg. Continue? [y/N]
```


* By default, nish's reaction for nim code is slow since Nim is a compiler language.
It is good to use [TCC](https://bellard.org/tcc/) for the compiler to speed up the reaction, so if you install nish by nimble, TCC will also be downloaded together.  
But if you are a Windows user, installing tcc is a bit complicated. when install nish by nimble, TCC will automatically download in current dir. So please move it somewhere and add the path of it.

* At present, you can not pass Nim's variable to a shell command directly.
# Todo

* Implement more commands
* Tab complement
