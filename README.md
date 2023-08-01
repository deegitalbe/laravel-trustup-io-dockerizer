# laravel-trustup-io-dockerizer
laravel-trustup-io-dockerizer

## Usage
Move your app to docker integration `projects` folder
Require sail in your app
```shell
composer require laravel/sail
```
Scaffold dockerization
```shell
npx @deegital/laravel-trustup-io-dockerizer@latest
```

## Development
```shell
./cli bootstrap #bootstrap project
./cli yarn install #install dependencies
./cli start #start project
./cli stop #stop project
./cli restart  #restart project
```