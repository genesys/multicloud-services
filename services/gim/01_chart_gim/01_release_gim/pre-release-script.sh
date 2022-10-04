######## Optional variables with defaults

# Postgres address
[[ "$POSTGRES_RPTHIST_ADDR" ]] && export POSTGRES_ADDR=$POSTGRES_RPTHIST_ADDR

# GIM DB credentials 
[[ -z "$gim_pgdb_etl_name" ]] && export gim_pgdb_etl_name=gim
[[ -z "$gim_pgdb_etl_user" ]] && export gim_pgdb_etl_user=gim
[[ -z "$gim_pgdb_etl_pass" ]] && export gim_pgdb_etl_pass=gim

# Creating GIM DB if not exist and init
create_pg_db gim_pgdb_etl_name gim_pgdb_etl_user gim_pgdb_etl_pass