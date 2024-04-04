# @deegital/laravel-trustup-io-deployment

## 1.0.0

### Major Changes

- 26a2c2e: Single package for laravel dockerization/deployment.

### Patch Changes

- 461d4ef: Installing dependencies correctly for stubs.

## 1.4.3

### Patch Changes

- f726cd9: Cluster autoscale parameter is compulsory true.

## 1.4.2

### Patch Changes

- 2ded063: Using optimized dockerfile for faster build process.

## 1.4.1

### Patch Changes

- b8c2f1e: Fallback application only if error occured during application rollout.
- a53b934: Forcing pods to stay alive while new pods are created during rollout.

## 1.4.0

### Minor Changes

- 8cc41c9: Using single job to speed up github action process. Avoiding loads of billing cost since github bills us at least 1min for each job even if it ends after 1sec.

### Patch Changes

- 0e70e04: Ignoring some files for docker in production environment.
- 95f6f12: Updating traefik values to new specification.

## 1.3.0

### Minor Changes

- b936d5e: Using release/v\*\* deployment hook. We're now able to push to any release branch and deploy staging environment.
- 5b75f02: Using registry cache for docker images build.

### Patch Changes

- e187427: Workaround for bucket DNS error. For unknown reason, digitalocean refuses cloudflare dns certificates. We have to execute a doctl command to magically let digitalocean autogenerate certificate.
- 5c40d47: Fixing several terraform issues. (storage volume mount, migration running once, keep application running during update, redis not saving snapshots, kubernetes size depending on environment)
- 6bcdeea: Using php8.2 as base for production docker composer build step. We were using composer image using any upcoming php version breaking image composer lock.

## 1.2.1

### Patch Changes

- 2c03e9e: Fixing boilerplate with real project.

## 1.2.0

### Minor Changes

- a19a8e0: Matching new requirements.

## 1.1.5

### Patch Changes

- b64443c: Avoiding minor kubernetes cluster upgrade.
- 5d2e7b3: Updating deprecated bucket cors configuration

## 1.1.4

### Patch Changes

- be3ad4b: Refactoring token service generation.

## 1.1.3

### Patch Changes

- b0e8e98: Adding staging branch to staging environment deployment.

## 1.1.2

### Patch Changes

- e882b13: Messed up db size.

## 1.1.1

### Patch Changes

- a55c335: Wrong migration init container.

## 1.1.0

### Minor Changes

- 19fcf38: Adding allowed ips to database firewall.

## 1.0.0

### Major Changes

- ef7291e: Moving to centralized workflow.

## 0.0.4

### Patch Changes

- 5715b87: Wrong .dockerignore modified
- 4c2e787: Messed up kubernetes kustomization path.

## 0.0.3

### Patch Changes

- a1a7e1d: Using correct folder as app key.

## 0.0.2

### Patch Changes

- ae8c499: Using dedicated terraform cloud workspace
