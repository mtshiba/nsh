# Package

version       = "0.2.1"
author        = "gmshiba"
description   = "nsh: Nim SHell(cross platform)"
license       = "MIT"
binDir        = "bin"
srcDir        = "src"
installDirs   = @["nshpkg"]
bin           = @["nsh", "tocl"]

# Dependencies

requires "nim >= 0.18.0"
# requires "unixcmd >= 0.1.0"
