## assumes we've already sintalled GO

export GOPATH=$HOME/go
go get -u golang.org/x/sys/...
go get github.com/fsnotify/fsnotify
go get github.com/prometheus/client_golang/prometheus
go get golang.org/x/sync/semaphore
go get -u go.uber.org/automaxprocs

go get github.com/google/zoekt/
go install github.com/google/zoekt/cmd/zoekt-index
go install github.com/google/zoekt/cmd/zoekt-webserver

