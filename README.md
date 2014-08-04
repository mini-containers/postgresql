# mini/postgresql

[PostgreSQL](http://www.postgresql.org/) container.

## Usage

To run this container and bind port `5432`:

```
docker run -d -p 5432:5432 mini/postgresql
```

You can now check the logs:

```
docker logs <CONTAINER_ID>
```

### Credentials

Credentials to access the PostgreSQL service are displayed in the container
logs for `admin` user.

### Setting a custom password

By default this container will generate a random password for `admin` user.
You can specify a fixed one by using `POSTGRESQL_PASS` environment variable:

```
docker run -d -p 5432:5432 -e POSTGRESQL_PASS=mystrongpassword mini/postgresql
```

This will only be set the first time the data volume is initialized.

### Data and volumes

This container exposes `/data` as bind mount volume. You can mount it
when starting the container:

```
docker run -v /mydata/mysql:/data -d -p 5432:5432 mini/postgresql
```

We recommend you mount the volume to avoid loosing data between updates to the
container.

## License

All the code contained in this repository, unless explicitly stated, is
licensed under ISC license.

A copy of the license can be found inside the [LICENSE](LICENSE) file.
