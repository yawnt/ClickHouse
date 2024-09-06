#!/usr/bin/env bash
# Tags: no-fasttest

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=../shell_config.sh
. "$CURDIR"/../shell_config.sh

DATA_DIR=$USER_FILES_PATH/$CLICKHOUSE_TEST_UNIQUE_NAME
mkdir -p $DATA_DIR
cp -r $CURDIR/data_hive/ $DATA_DIR

$CLICKHOUSE_CLIENT --query_id="test_03231_1_$CLICKHOUSE_TEST_UNIQUE_NAME" --query "
    SELECT countDistinct(_path) FROM file('$DATA_DIR/data_hive/partitioning/column0=*/sample.parquet') WHERE column0 = 'Elizabeth' SETTINGS use_hive_partitioning=1;
"

$CLICKHOUSE_CLIENT --query "
    SYSTEM FLUSH LOGS;
"

$CLICKHOUSE_CLIENT --query "
    SELECT ProfileEvents['EngineFileLikeReadFiles'] FROM system.query_log WHERE query_id='test_03231_1_$CLICKHOUSE_TEST_UNIQUE_NAME' AND current_database = currentDatabase() and type='QueryFinish';
"

$CLICKHOUSE_CLIENT --query_id="test_03231_2_$CLICKHOUSE_TEST_UNIQUE_NAME" --query "
    SELECT countDistinct(_path) FROM file('$DATA_DIR/data_hive/partitioning/identifier=*/email.csv') WHERE identifier = 2070 SETTINGS use_hive_partitioning=1;
"

$CLICKHOUSE_CLIENT --query "
    SYSTEM FLUSH LOGS;
"

$CLICKHOUSE_CLIENT --query "
    SELECT ProfileEvents['EngineFileLikeReadFiles'] FROM system.query_log WHERE query_id='test_03231_2_$CLICKHOUSE_TEST_UNIQUE_NAME' AND current_database = currentDatabase() and type='QueryFinish';
"

$CLICKHOUSE_CLIENT --query_id="test_03231_3_$CLICKHOUSE_TEST_UNIQUE_NAME" --query "
    SELECT countDistinct(_path) FROM file('$DATA_DIR/data_hive/partitioning/array=*/sample.parquet') WHERE array = [1,2,3] SETTINGS use_hive_partitioning=1;
"

$CLICKHOUSE_CLIENT --query "
    SYSTEM FLUSH LOGS;
"

$CLICKHOUSE_CLIENT --query "
    SELECT ProfileEvents['EngineFileLikeReadFiles'] FROM system.query_log WHERE query_id='test_03231_3_$CLICKHOUSE_TEST_UNIQUE_NAME' AND current_database = currentDatabase() and type='QueryFinish';
"
rm -rf $DATA_DIR
