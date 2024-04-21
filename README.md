# laravel-trustup-io-deployment

Scaffolding deployments folder for our laravel projects

## Usage

### Fresh laravel application

Inside your `projects` folder

```shell
docker run --rm \
    --interactive \
    --tty \
    --volume $PWD:/opt/apps/app \
    --workdir /opt/apps/app \
    --user $(id -u):$(id -g) \
    henrotaym/laravel-installer:latest
```

### Dockerize application

Inside your app folder

```shell
npx @deegital/laravel-trustup-io-dockerizer@latest
```
