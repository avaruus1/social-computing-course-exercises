-- SQLite prompt table listing command: .tables
-- SQLite prompt table schema command: .schema <table_name>

-- Pure SQL alternative, if required:
SELECT * FROM sqlite_master WHERE type = 'table' AND tbl_name != 'sqlite_sequence';
