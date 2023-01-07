# Google Cloud SQL

A CloudSQL demo setup, that could be used to demonstrate application integrations with Google Cloud SQL.

## Set `postgres` user password

Generate the `gcloud` command to set or reset the `postgres` user password,

```shell
echo -n "gcloud sql users set-password postgres \
--instance="$(terraform output db_instance_connection_name)" \
--prompt-for-password"
```

Launch a __Cloud Shell__ and run the output of the above command to set the new password for `postgres` user.

>IMPORTANT: Be sure to remember this password

## Connect

Generate the `psql` connect command,

```shell
echo -n "psql \"host=127.0.0.1 port=5432 sslmode=disable dbname=$(terraform output default_database) user=postgres\""
```

Launch another __Cloud Shell__ and run the output of the above command.

## Grants

Generate the grant command,

```shell
echo -n "GRANT ALL PRIVILEGES ON DATABASE $(terraform output -raw default_database) TO $(terraform output db_admin_user);"
```

Run the following grant statement on the `psql` prompt to grant all privileges to `db_admin_user`
