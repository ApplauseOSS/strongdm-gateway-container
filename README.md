# strongdm-gateway-container

Creates a container image which will automatically register itself as a strongDM gateway. This requires that the
variable `SDM_ADMIN_TOKEN` is passed to the container. Otherwise, the entrypoint script will exit.

Adapted from SDM docs: https://www.strongdm.com/docs/admin-guide/self-registering-relay/

## Building

Build this just like any other container image

```bash
docker build --rm -t gateway .
```

## Usage

Run a self-registering gateway in Docker on the default port, using container hostname as register address
```
docker run -e SDM_ADMIN_TOKEN=${SDM_ADMIN_TOKEN} -p5000:5000 gateway
```

There are several environment variables which can be used to control this container.

- `SDM_ADMIN_TOKEN` (required) - Set to an admin token with at least `relay:create` permissions
- `SDM_RELAY_ADDR` - Set this to the listen address of the container, this may be `$(POD_IP)` in Kubernetes
- `SDM_RELAY_PORT` - Set the port to listen on both outside and inside the container
- `SDM_RELAY_NAME` - Set the name given to this relay in strongDM (must be unique)
