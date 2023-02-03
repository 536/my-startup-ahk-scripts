SplitPath, % A_Args[1], , OutDir
Run, % A_ComSpec " /k cd /d """ OutDir """ && venv"
