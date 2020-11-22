
DATA_DIR=data

json:
	@ perl bin/csv_to_json $(DATA_DIR)/planetary_data_*.csv

test:
	prove $(< t/test_manifest)

cover:
	cover -delete
	cover -test
