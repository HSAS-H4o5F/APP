#  This file is part of hsas_h4o5f_app.
#  Copyright (c) 2023 HSAS H4o5F Team. All Rights Reserved.
#
#  hsas_h4o5f_app is free software: you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by the Free
#  Software Foundation, either version 3 of the License, or (at your option) any
#  later version.
#
#  hsas_h4o5f_app is distributed in the hope that it will be useful, but WITHOUT
#  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
#  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
#  details.
#
#  You should have received a copy of the GNU General Public License along with
#  hsas_h4o5f_app. If not, see <https://www.gnu.org/licenses/>.

import os
import sys

import yaml

if len(sys.argv) > 1:

    file = open(os.path.abspath("pubspec.yaml"), "r")
    data = yaml.safe_load(file)
    file.close()

    data['version'] = data['version'].replace("+", "-{}+".format(sys.argv[1]))

    file = open(os.path.abspath("pubspec.yaml"), "w")
    yaml.dump(data, file, default_flow_style=False)
    file.close()

os.system("dart run build_runner build --delete-conflicting-outputs")
os.system("dart run vector_graphics_compiler --input-dir assets/vectors")
