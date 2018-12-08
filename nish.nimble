# Installing external compiler (tcc)

when defined(Windows):
    when defined(amd64):
        exec "installwin64.bat"
    when defined(x86):
        exec "installwin32.bat"
elif defined(MacOSX) or defined(MacOS):
    exec "brew install tcc"
elif defined(Linux):
    exec "sudo apt-get install tcc"
    # or
    exec "sudo yum install tcc"

# Package

version       = "0.1.1"
author        = "gmshiba"
description   = "nish: NIm SHell(cross platform)"
license       = "MIT"
binDir        = "bin"
srcDir        = "src"
installDirs   = @["nishpkg"]
bin           = @["nish"]

# Dependencies

requires "nim >= 0.18.0"
# requires "unixcmd >= 0.1.0"
