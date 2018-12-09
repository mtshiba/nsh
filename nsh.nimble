# Installing external compiler (tcc)

when defined(Windows):
    # when defined(amd64):
    #    exec "installwin64.bat"
    # when defined(x86):
    #    exec "installwin32.bat"
    discard
elif defined(MacOSX) or defined(MacOS):
    exec "brew install tcc"
elif defined(Linux):
    try:
        exec "apt-get -y update"
        exec "apt-get -y install tcc"
    # or
    except:
        try:
            exec "yum -y update"
            exec "yum -y install tcc"
        except:
            try:
                exec "npm -g install tcc"
            except:
                echo "Sorry I failed to install tcc. Please install manually."

# Package

version       = "0.1.5"
author        = "gmshiba"
description   = "nsh: Nim SHell(cross platform)"
license       = "MIT"
binDir        = "bin"
srcDir        = "src"
installDirs   = @["nshpkg"]
bin           = @["nsh"]

# Dependencies

requires "nim >= 0.18.0"
# requires "unixcmd >= 0.1.0"
