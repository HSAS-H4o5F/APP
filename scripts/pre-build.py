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

import logging
import os
import sys

import yaml

logging.basicConfig(level=logging.DEBUG)
logging.info("Running pre-build script.")

if len(sys.argv) > 1:
    logging.info("Opening pubspec.yaml for reading.")
    file = open(os.path.abspath("pubspec.yaml"), "r")

    logging.info("Loading pubspec data.")
    data = yaml.safe_load(file)
    file.close()

    logging.info("Replacing version with {}.".format(sys.argv[1]))
    data['version'] = data['version'].replace("+", "-{}+".format(sys.argv[1]))

    logging.info("Opening pubspec.yaml for writing.")
    file = open(os.path.abspath("pubspec.yaml"), "w")

    logging.info("Dumping pubspec data.")
    yaml.dump(data, file, default_flow_style=False)
    file.close()

logging.info("Running build_runner.")
os.system("dart run build_runner build --delete-conflicting-outputs")

logging.info("Running vector_graphics_compiler.")
os.system("dart run vector_graphics_compiler --input-dir assets/vectors")
