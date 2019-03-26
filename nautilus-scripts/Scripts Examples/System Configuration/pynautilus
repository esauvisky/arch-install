#!/usr/bin/env python


"""
This function extracts Nautilus variables from the environment, splits them on
newlines and puts results in dictionary.

Example:

	ala = parse_nautilus_environment()

	for tmp in ala['NAUTILUS_SCRIPT_SELECTED_FILE_PATHS']:
		print tmp

"""

def parse_nautilus_environment():
	import os
	
	result = {
		'NAUTILUS_SCRIPT_SELECTED_FILE_PATHS' : [],
		'NAUTILUS_SCRIPT_SELECTED_URIS' : [],
		'NAUTILUS_SCRIPT_CURRENT_URI' : [],
		'NAUTILUS_SCRIPT_WINDOW_GEOMETRY' : [] # I wonder if anyone uses it ;)
	}

	for i in result.keys():
		if os.environ.has_key(i):
			result[i] = os.environ[i].split(':')
		else:
			result[i] = []
	
	return result



