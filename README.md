## `buildkit` push strangeness

This `README` explains how, using the reproducer in this repository, we see
strange behaviour when `docker buildx build --push` is used with different
`--platform` flag values.

Specifically, that it appears the digest returned by `docker pull` literally
refers to the latest push, not the latest push for the target platform.

```
# Build and push both linux/amd64 and linux/arm64
$ docker buildx build --progress plain --push --platform linux/arm64,linux/amd64 -t myitcv/hello .
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 564B done
#1 DONE 0.0s

...
#17 pushing manifest for docker.io/myitcv/hello:latest@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
#17 pushing manifest for docker.io/myitcv/hello:latest@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d 0.6s done
#17 DONE 1.4s

# Pull the latest image
$ docker pull myitcv/hello
Using default tag: latest
latest: Pulling from myitcv/hello
Digest: sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
Status: Image is up to date for myitcv/hello:latest
docker.io/myitcv/hello:latest

# Use the digest from the latest pull to run the linux/arm64 image
$ docker run --rm --platform linux/arm64 -it myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
Hello world, GOOS=linux, GOARCH=arm64

# Remove the image so that we can run the linux/amd64 image
$ docker rmi myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
Untagged: myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d

# Use the digest from the latest pull to run the linux/amd64 image
$ docker run --rm --platform linux/amd64 -it myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
Unable to find image 'myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d' locally
docker.io/myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d: Pulling from myitcv/hello
59bf1c3509f3: Pull complete
467e4f6ddfaf: Pull complete
f0bc0078139a: Pull complete
Digest: sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
Status: Downloaded newer image for myitcv/hello@sha256:4728bf06883a21705ac2b6056ae42a27a3aa5aff36369eb95504d5bcceac1c8d
WARNING: image with reference myitcv/hello was found but does not match the specified platform: wanted linux/amd64, actual: linux/arm64
Hello world, GOOS=linux, GOARCH=amd64

$ docker buildx build --progress plain --push --platform linux/arm64 -t myitcv/hello .
#1 [internal] load build definition from Dockerfile
#1 transferring dockerfile: 564B done
#1 DONE 0.0s

...

# Build and push only linux/arm64
#12 pushing manifest for docker.io/myitcv/hello:latest@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
#12 pushing manifest for docker.io/myitcv/hello:latest@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71 0.5s done
#12 DONE 1.7s

# Pull to get the latest digest
$ docker pull myitcv/hello
Using default tag: latest
latest: Pulling from myitcv/hello
Digest: sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
Status: Image is up to date for myitcv/hello:latest
docker.io/myitcv/hello:latest


# Use the digest from the latest pull to run the linux/arm64 image
$ docker run --rm --platform linux/arm64 -it myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
Hello world, GOOS=linux, GOARCH=arm64


# Remove the image so that we can run the linux/amd64 image
$ docker rmi myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
Untagged: myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71

# Use the digest from the latest pull to run the linux/amd64 image
$ docker run --rm --platform linux/amd64 -it myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
Unable to find image 'myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71' locally
docker.io/myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71: Pulling from myitcv/hello
Digest: sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
Status: Downloaded newer image for myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71
WARNING: image with reference myitcv/hello was found but does not match the specified platform: wanted linux/amd64, actual: linux/arm64
docker: Error response from daemon: image with reference myitcv/hello@sha256:fc761b0d231b8be7f3450fe4d3750fccff0ba2100d000597813e3ba0eec82e71 was found but does not match the specified platform: wanted linux/amd64, actual: linux/arm64.
See 'docker run --help'.
```

