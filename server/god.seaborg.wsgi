import os, sys

sys.path.append(os.path.dirname(__file__))
os.chdir(os.path.dirname(__file__))

import bottle
bottle.debug(True)


import seaborg.server


application = bottle.default_app()

