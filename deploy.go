package main

import (
	"log"
	"os"
	"path/filepath"

	"github.com/pkg/errors"
)

func deploy() error {
	for _, server := range servers {
		log.Printf("uploading artifacts server=%s arch=%s\n",
			server.name, server.arch)
		err := runcmd("rsync",
			"--archive",
			"--progress",
			"--filter", "+ *"+server.arch+".tar.xz",
			"--filter", "- *",
			"--checksum",
			"--delete",
			artifactDir()+"/",
			server.user+"@"+server.name+":/opt/artifacts/",
		)
		if err != nil {
			return errors.Wrapf(err, "failed to upload artifacts server=%s", server.name)
		}

		etcDir := filepath.Join(os.Getenv("GOPATH"), "src", "github.com", "badgerodon", "infrastructure", "prod", "etc")
		log.Printf("updating config server=%s arch=%s\n",
			server.name, server.arch)
		err = runcmd("rsync",
			"--archive",
			"--progress",
			"--checksum",
			etcDir+"/",
			server.user+"@"+server.name+":/etc/",
		)
		if err != nil {
			return errors.Wrapf(err, "failed to upload config server=%s", server)
		}

		scriptDir := filepath.Join(os.Getenv("GOPATH"), "src", "github.com", "badgerodon", "infrastructure", "scripts")
		log.Printf("uploading scripts server=%s arch=%s\n",
			server.name, server.arch)
		err = runcmd("rsync",
			"--archive",
			"--progress",
			"--checksum",
			scriptDir+"/",
			server.user+"@"+server.name+":/tmp/",
		)
		if err != nil {
			return errors.Wrapf(err, "failed to upload scripts server=%s", server)
		}

		for _, appName := range server.applications {
			app := applications[appName]

			log.Printf("installing server=%s arch=%s app=%s\n",
				server.name, server.arch, app.name)
			err = runcmd("ssh",
				server.user+"@"+server.name,
				"chmod +x /tmp/install-app.bash && env "+
					"APP="+app.name+" "+
					"VERSION="+app.version+" "+
					"ARCH="+server.arch+" "+
					"/tmp/install-app.bash",
			)
			if err != nil {
				return errors.Wrapf(err, "failed to install server=%s arch=%s app=%s",
					server.name, server.arch, app.name)
			}
		}
	}
	return nil
}

/*

# CONFIG
echo -e "[DEPLOY] updating config $COL_GREY"
rsync \
    --archive \
    --progress \
    --recursive \
    --checksum \
    ./prod/etc/ \
    root@m1.badgerodon.com:/etc/
ssh root@m1.badgerodon.com "systemctl daemon-reload"
echo -e "$COL_RESET"

# SCRIPTS
echo -e "[DEPLOY] installing $COL_GREY"
rsync \
    --archive \
    --progress \
    --checksum \
    ./scripts/ \
    root@m1.badgerodon.com:/tmp
ssh root@m1.badgerodon.com "chmod +x /tmp/install-app.bash && env APP=caddy ARCH=arm64 /tmp/install-app.bash"
echo -e "$COL_RESET"


*/
