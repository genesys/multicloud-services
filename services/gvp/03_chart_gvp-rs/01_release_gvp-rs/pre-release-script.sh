# These variables, if not defined in your deployment secrets,
# will be taken from global defaults:
[[ ! "$gvp_mssql_db_server" ]] && export gvp_mssql_db_server=$MSSQL_ADDR
[[ ! "$gvp_rs_mssql_admin_password" ]] && export gvp_rs_mssql_admin_password=$MSSQL_ADMIN_PASSWORD
[[ ! "$gvp_rs_mssql_reader_password" ]] && export gvp_rs_mssql_reader_password=$MSSQL_ADMIN_PASSWORD
[[ ! "$gvp_rs_mssql_db_name" ]] && export gvp_rs_mssql_db_name="gvp_rs"
[[ ! "$gvp_rs_mssql_db_user" ]] && export gvp_rs_mssql_db_user="mssqladmin"
[[ ! "$gvp_rs_mssql_db_password" ]] && export gvp_rs_mssql_db_password=$MSSQL_ADMIN_PASSWORD

if ! (kubectl get job init-mssql-for-gvp-rs-job | grep '1/1' >/dev/null)
then

kubectl delete job init-mssql-for-gvp-rs-job || true
kubectl create job init-mssql-for-gvp-rs-job --image=mcr.microsoft.com/mssql-tools -- \
sh -c "cat <<EOF | /opt/mssql-tools/bin/sqlcmd -S $gvp_mssql_db_server -U sa -P "$gvp_rs_mssql_admin_password" -i /dev/stdin -o /dev/stdout               
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = '$gvp_rs_mssql_db_name')
BEGIN
  CREATE DATABASE [$gvp_rs_mssql_db_name];
END;
GO

CREATE LOGIN $gvp_rs_mssql_db_user WITH PASSWORD = '$gvp_rs_mssql_db_password';
GO

USE [$gvp_rs_mssql_db_name];
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'$gvp_rs_mssql_db_user')
BEGIN
    CREATE USER [$gvp_rs_mssql_db_user] FOR LOGIN [$gvp_rs_mssql_db_user]
    EXEC sp_addrolemember N'db_owner', N'$gvp_rs_mssql_db_user'
    EXEC sp_addrolemember N'db_ddladmin', N'$gvp_rs_mssql_db_user'
END;
GO

CREATE LOGIN mssqlreader WITH PASSWORD = '$gvp_rs_mssql_reader_password';
GO

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'mssqlreader')
BEGIN
    CREATE USER [mssqlreader] FOR LOGIN [mssqlreader]
    EXEC sp_addrolemember N'db_datareader', N'mssqlreader'
END;
GO

SELECT name,create_date from sys.server_principals WHERE type in ('s', 'u')
GO
"
fi

###############################################################################
#   Secrets for GVP Reporting Server
#   https://all.docs.genesys.com/GVP/Current/GVPPEGuide/Deploy#Secrets_creation_3
###############################################################################

kubectl create secret generic rs-dbreader-password \
  --from-literal=db_hostname=$gvp_mssql_db_server \
  --from-literal=db_name=$gvp_rs_mssql_db_name \
  --from-literal=db_password=$gvp_rs_mssql_db_password \
  --from-literal=db_username=$gvp_rs_mssql_db_user \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic shared-gvp-rs-sqlserver-secret \
  --from-literal=db-admin-password=$gvp_rs_mssql_db_password \
  --from-literal=db-reader-password=$gvp_rs_mssql_reader_password \
  --dry-run=client -o yaml | kubectl apply -f -
