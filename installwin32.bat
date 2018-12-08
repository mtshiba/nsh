bitsadmin /TRANSFER tccget http://download.savannah.gnu.org/releases/tinycc/tcc-0.9.27-win32-bin.zip %CD%\\tcc-bin.zip"
powershell Expand-Archive -Path tcc-bin.zip
rm -f tcc-bin.zip
