dim shell
set shell = WScript.CreateObject("WScript.Shell")

dim env
set env = shell.Environment("SYSTEM")
dim dir
dim fso
set fso = createObject("Scripting.FileSystemObject")
dir = fso.getParentFolderName(WScript.ScriptFullName)
'WScript.Echo(dir)
'WScript.Echo(env.item("PATH"))
env.item("PATH") = env.item("PATH") & ";" & dir & "\tcc-bin\tcc"
