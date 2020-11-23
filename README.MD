# Overview

This repo was put together to help benchmark Docker's `buildkit` build engine against the default docker image builder.

# Methodology

The different build engines were tested against a couple of build scenarios we run into with some regularity:

* Building a fresh image from scratch
* Rebuilding an image without any changes
* Rebuilding an image after there have been code changes
* Rebuilding an image after a Python dependency has been added/updated/removed
* Rebuilding an image after a System package has been added/updated/removed

By testing each different scenario we can evaluate now only any performance differences in the build engine but also how their different approaches to caching will impact build speed.

All images referenced in the Dockerfile, or images created or pulled while running these benchmarks, were provided by a local registry running in Docker.


While testing the default docker builder I ran into issues with caching.  If I built and image, pushed it to a registry, deleted the image locally, and re-pulled the image from the registry many (most) of the layers resulted in a cache miss.  If I built the image, left it in place, and re-ran the build then all layers hit the cache as expected.

This is not realistic in a distributed CI environment, but as this is primarily an exploration of how the builders stack up I'm going with the default builder's best case scenario.  Just keep in mind that in a CI environment the built-in docker will likely perform much, much worse.

# Buildkit Benchmarks

To trigger a build with all caching disabled, run the following command:

```shell
    ./baseline.sh ./cache_test/Dockerfile ./cache_test/ localhost:5000/cache_test 2>&1 | tee output/baseline.log
```

To trigger a build with caching enabled, run the following command:

```shell
    ./cached.sh ./cache_test/Dockerfile ./cache_test/ localhost:5000/cache_test 2>&1 | tee output/cached.log
```

_Note_: When running with caching enabled, the last successfully built image will be the cache source for the new build.

## Build without caching
| Builder  | Real      | User     | System   |
| -------- | --------- | -------- | -------- |
| docker   | 0m49.947s | 0m2.028s | 0m1.753s |
| buildkit | 0m28.808  | 0m0.158s | 0m0.158s |

## Build with caching
| Builder  | Real     | User     | System   |
| -------- | -------- | -------- | -------- |
| docker   | 0m4.003s | 0m1.909s | 0m1.496s |
| buildkit | 0m0.268s | 0m0.122s | 0m0.063s |

## Build after updating code
| Builder  | Real      | User     | System   |
| -------- | --------- | -------- | -------- |
| docker   | 0m16.964s | 0m1.932s | 0m1.562s |
| buildkit | 0m2.629s  | 0m0.125s | 0m0.068s |

## Build after updating dependency
| Builder  | Real      | User     | System   |
| -------- | --------- | -------- | -------- |
| docker   | 0m28.813s | 0m1.878s | 0m1.463s |
| buildkit | 0m15.332s | 0m0.136s | 0m0.074s |

## Build after updating system package
| Builder  | Real      | User     | System   |
| -------- | --------- | -------- | -------- |
| docker   | 0m49.689s | 0m1.970s | 0m1.526s |
| buildkit | 0m30.468s | 0m0.166s | 0m0.099s |
