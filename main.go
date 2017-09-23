package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
	"github.com/pkg/errors"
)

type application struct {
	name     string
	version  string
	builders []builder
}

func (app *application) artifactPath(arch string) string {
	return filepath.Join(artifactDir(),
		fmt.Sprintf("%s_%s_linux_%s.tar.gz", app.name, app.version, arch),
	)
}

type server struct {
	name         string
	arch         string
	applications []string
	user         string
}

var (
	applications = map[string]*application{
		"badgerodon-www": {
			name:    "badgerodon-www",
			version: "0.1.0",
			builders: []builder{
				newGoBuilder(goProjectPath("badgerodon", "www")),
				newCopyBuilder(goProjectPath("badgerodon", "www"), "assets"),
				newCopyBuilder(goProjectPath("badgerodon", "www"), "tpl"),
			},
		},
		"traefik": {
			name:    "traefik",
			version: "1.3.8",
			builders: []builder{
				newTraefikBuilder(),
			},
		},
	}
	servers = []*server{
		{
			name:         "m1.badgerodon.com",
			arch:         "amd64",
			applications: []string{"traefik", "badgerodon-www"},
			user:         "root",
		},
	}
)

func main() {
	log.SetFlags(0)

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "usage: %s build|deploy \n", filepath.Base(os.Args[0]))
		flag.PrintDefaults()
	}
	flag.Parse()

	var err error
	switch flag.Arg(0) {
	case "build":
		err = build(flag.Arg(1))
	case "deploy":
		err = deploy()
	default:
		flag.Usage()
		return
	}
	if err != nil {
		log.Fatal(err)
	}
}

func artifactDir() string {
	root := os.Getenv("ARTIFACT_DIR")
	if root == "" {
		root = filepath.Join(os.Getenv("HOME"), "badgerodon", "artifacts")
	}
	return root
}

func goProjectPath(org, repo string) string {
	return filepath.Join(os.Getenv("GOPATH"), "src", "github.com", org, repo)
}

func dockerArch(arch string) string {
	if arch == "arm64" {
		return "arm64v8"
	}
	return arch
}

func runcmd(name string, args ...string) error {
	printer := color.New(color.Faint)

	var strargs []string

	cmd := exec.Command(name, args...)
	strargs = append(strargs, name)
	strargs = append(strargs, args...)
	printer.Fprintf(os.Stdout, "[%s] † %s\n", name, strings.Join(strargs, " "))

	stderr, err := cmd.StderrPipe()
	if err != nil {
		return errors.Wrap(err, "failed to get stderr pipe")
	}
	go func() {
		defer stderr.Close()
		s := bufio.NewScanner(stderr)
		for s.Scan() {
			printer.Fprintf(os.Stderr, "[%s] %s\n", name, s.Text())
		}
	}()

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return errors.Wrap(err, "failed to get stdout pipe")
	}
	go func() {
		defer stdout.Close()
		s := bufio.NewScanner(stdout)
		for s.Scan() {
			printer.Fprintf(os.Stdout, "[%s] %s\n", name, s.Text())
		}
	}()

	return cmd.Run()
}
