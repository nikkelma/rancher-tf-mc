package installrancher

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestAwsInstallRancher(t *testing.T) {
	cwd, err := os.Getwd()
	if err != nil {
		t.Fatalf("couldn't get working directory: %s", err)
	}

	terraformDir, err := filepath.Abs("../../../../00-rancher-server/terraform/root/rancher")
	if err != nil {
		t.Fatalf("couldn't resolve absolute terraform directory: %s", err)
	}

	kubeConfigPath, err := filepath.Abs(filepath.Join(cwd, "kube_config.yaml"))
	if err != nil {
		t.Fatalf("couldn't resolve absolute kube config path: %s", err)
	}

	varFilePath, err := filepath.Abs(filepath.Join(cwd, "install_rancher.tfvars"))
	if err != nil {
		t.Fatalf("couldn't resolve absolute terraform variables path: %s", err)
	}

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,

		Vars: map[string]interface{}{
			"config_path": kubeConfigPath,
		},
		VarFiles: []string{varFilePath},
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	hostname := terraform.Output(t, terraformOptions, "rancher_hostname")

	http_helper.HTTPDoWithRetry(t, "GET",
		"https://"+hostname+"/ping",
		[]byte("pong"),
		nil,
		200,
		60,
		10*time.Second,
		nil,
	)

	logger.Log(t, "Rancher server is up and running! Sleeping for 30 seconds...")
	time.Sleep(30 * time.Second)
}
