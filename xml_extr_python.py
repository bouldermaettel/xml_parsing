import pandas as pd
import numpy as np
import xml.etree.cElementTree as et

tree=et.parse('anwender/final-anwender.xml')
root=tree.getroot()

list(root[0])