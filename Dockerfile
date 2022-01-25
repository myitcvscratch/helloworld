FROM --platform=$BUILDPLATFORM golang@sha256:0fa6504d3f1613f554c42131b8bf2dd1b2346fb69c2fc24a312e7cba6c87a71e AS stage1

ENV GOCACHE=/root/.cache/go/gocache
ENV GOMODCACHE=/root/.cache/go/gomodcache
ENV GOPATH=

ARG TARGETOS TARGETARCH
ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH

COPY . .

RUN --mount=type=cache,target=/root/.cache/go go build -o hello .

FROM alpine@sha256:21a3deaa0d32a8057914f36584b5288d2e5ecc984380bc0118285c70fa8c9300

RUN mkdir /runbin
COPY --from=stage1 /go/hello /runbin
ENTRYPOINT ["/runbin/hello"]
