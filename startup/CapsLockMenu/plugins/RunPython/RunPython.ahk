SplitPath, % A_Args[1], OutFileName, OutDir
Run, % A_ComSpec " /k cd /d """ OutDir """ && python " OutFileName
