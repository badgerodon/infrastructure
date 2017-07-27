package main

import (
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/pkg/errors"
)

func build() error {
	for _, arch := range []string{"amd64", "arm64"} {
		for _, app := range applications {
			if _, err := os.Stat(app.artifactPath(arch)); err == nil {
				log.Printf("skipping because artifact already exists app=%s arch=%s artifact=%s\n",
					app.name, arch, app.artifactPath(arch))
				continue
			}

			tmp, err := ioutil.TempDir("/tmp", "build-go")
			if err != nil {
				return errors.Wrap(err, "failed to get temporary directory")
			}
			defer os.RemoveAll(tmp)

			builders := append(app.builders[:len(app.builders):len(app.builders)],
				&artifactBuilder{},
			)
			for i, builder := range builders {
				log.Printf("building app=%s arch=%s step=%d builder=%v\n", app.name, arch, i, builder)
				err = builder.build(app, arch, tmp)
				if err != nil {
					return errors.Wrapf(err, "failed to build application arch=%s step=%d builder=%v",
						arch, i, builder)
				}
			}
		}
	}
	return nil
}

type builder interface {
	build(app *application, arch, dst string) error
}

type goBuilder struct {
	root string
}

func newGoBuilder(root string) *goBuilder {
	return &goBuilder{root: root}
}

func (b *goBuilder) build(app *application, arch, dst string) error {
	parts := strings.SplitN(b.root, "/src/", 2)
	if len(parts) < 2 {
		return errors.Errorf("root does not appear to be a valid GOPATH root=%s", b.root)
	}

	return runcmd("docker", "run",
		"-v", filepath.Join(parts[0], "pkg")+":/root/pkg",
		"-v", filepath.Join(parts[0], "src")+":/root/src",
		"-v", dst+":/out",
		"-i",
		"badgerodon/"+dockerArch(arch)+"-base",
		"go", "build",
		"-i",
		"-o", "/out/"+app.name,
		parts[1],
	)
}

type copyBuilder struct {
	root, dir string
}

func newCopyBuilder(root, dir string) *copyBuilder {
	return &copyBuilder{root: root, dir: dir}
}

func (b *copyBuilder) build(app *application, arch, dst string) error {
	os.MkdirAll(filepath.Join(dst, b.dir), 0755)
	return runcmd("cp", "-r", filepath.Join(b.root, b.dir), filepath.Join(dst, b.dir))
}

type artifactBuilder struct{}

func (b *artifactBuilder) build(app *application, arch, dst string) error {
	return runcmd("tar",
		"-cJ",
		"-f", app.artifactPath(arch),
		"-C", dst,
		".",
	)
}
