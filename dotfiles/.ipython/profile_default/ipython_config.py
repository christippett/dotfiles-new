# auto reload python modules - https://stackoverflow.com/a/13961334
c.InteractiveShellApp.exec_lines = ["%load_ext autoreload", "%autoreload 2"]
