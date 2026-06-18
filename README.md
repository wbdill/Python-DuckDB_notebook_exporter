# Python-DuckDB_notebook_exporter

The DuckDB UI is great at quick and dirty SQL queries for DuckDB, however it lacks the ability to easily export the SQL from one or more notebooks.

The Jupyter notebooks in the repo allow you to export SQL code from DuckDB UI notebooks in either JSON format (how it is stored internally in a DuckDB database) or SQL format with line comments between each SQL cell.

**NOTE**: You must terminate any duckdb -ui sessions before using these exporter utilites because any existing ui session will have a lock on the duckdb database that stores the notebooks and their sql cells.

## First Time Use

If you don't already have these packages installed:
- duckdb
- pandas
- ipython

Then run this to install them from command line:

`python -m pip install -r requirements.txt`

## Design Decisions

I have preserved the semantics of the JSON payload for each notebook (all the same elements and preserved order of the array of cells) but have intentionally made the following changes:
1. I have a line break after every cell object so that the JSON file has one line per cell in the output
2. I have reordered the elements within each cell object with the query last and the shorter elements (cellId and useDatabase) appear first

These two changes make the JSON file MUCH more human readable and one line per cell makes it much more source control friendly.  If you only edit one cell, then only that one line will have any changes
