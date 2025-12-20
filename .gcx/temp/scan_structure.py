import os

def list_files(startpath):
    structure = ""
    for root, dirs, files in os.walk(startpath):
        level = root.replace(startpath, '').count(os.sep)
        indent = ' ' * 4 * (level)
        structure += '{}{}/\n'.format(indent, os.path.basename(root))
        subindent = ' ' * 4 * (level + 1)
        for f in files:
            structure += '{}{}\n'.format(subindent, f)
    return structure

be_struct = list_files('platform/backend/src')
fe_struct = list_files('platform/frontend/app')
fe_comp = list_files('platform/frontend/components')

with open('.gcx/project_structure.txt', 'w', encoding='utf-8') as f:
    f.write("=== Backend Structure ===\n")
    f.write(be_struct)
    f.write("\n=== Frontend Structure ===\n")
    f.write(fe_struct)
    f.write(fe_comp)
