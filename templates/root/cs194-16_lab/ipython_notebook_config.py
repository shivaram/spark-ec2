# Configuration file for ipython-notebook.
c = get_config()

# Notebook config
c.NotebookApp.certfile = u'/root/mycert.pem'
c.NotebookApp.ip = '*'
c.NotebookApp.open_browser = False
# It is a good idea to put it on a known, fixed port
c.NotebookApp.port = 8888

PWDFILE="/root/.ipython/profile_default/nbpasswd.txt"
c.NotebookApp.password = open(PWDFILE).read().strip()
