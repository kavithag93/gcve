/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package nsxt_lb_virtual_server

import (
	"os"
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	api "github.com/vmware/go-vmware-nsxt"
	"github.com/vmware/go-vmware-nsxt/loadbalancer"
)

func TestNsxtLoadBalancerVirtualServer(t *testing.T) {
	insecure, _ := strconv.ParseBool(os.Getenv("NSXT_ALLOW_UNVERIFIED_SSL"))
	username := os.Getenv("NSXT_USERNAME")
	password := os.Getenv("NSXT_PASSWORD")
	host := os.Getenv("NSXT_MANAGER_HOST")
	projects_backend_bucket := os.Getenv("TF_BACKEND_BUCKET")

	backendConfig := map[string]interface{}{
		"bucket": projects_backend_bucket,
	}

	cfg := api.Configuration{
		BasePath: "/api/v1",
		Host:     host,
		Scheme:   "https",
		UserName: username,
		Password: password,
		Insecure: insecure,
	}
	nsxClient, err := api.NewAPIClient(&cfg)
	if err != nil {
		panic(err)
	}

	bpt := tft.NewTFBlueprintTest(t,
		tft.WithBackendConfig(backendConfig),
	)

	bpt.DefineVerify(func(assert *assert.Assertions) {

		bpt.DefaultVerify(assert)
		nsxt_virtual_server_path := bpt.GetStringOutput("nsxt_virtual_server_path")
		lb_vs, _, err1 := nsxClient.ServicesApi.ListLoadBalancerVirtualServers(nsxClient.Context, nil)
		if err1 != nil {
			panic(err1)
		}
		var lbVs loadbalancer.LbVirtualServer
		for _, v := range lb_vs.Results {
			path := v.Tags[0].Tag
			if path == nsxt_virtual_server_path {
				lbVs = v
			}
		}
		assert.Equal("cft-test-lb-virtual-server", lbVs.DisplayName, "LB Virtual Server Display Name should be same")
		assert.Equal(true, lbVs.Enabled, "LB Virtual Server should be enabled")
		assert.Equal(true, lbVs.AccessLogEnabled, "LB Virtual Server AccessLogEnabled should be enabled")
		assert.Equal("192.168.1.100", lbVs.IpAddress, "LB Virtual Server IpAddress should be enabled")
		assert.Equal([]string{"80"}, lbVs.Ports, "LB Virtual Server Ports should be same")
		assert.Equal([]string{"80"}, lbVs.DefaultPoolMemberPorts, "LB Virtual Server DefaultPoolMemberPorts should be same")
		assert.Equal(int64(10), lbVs.MaxConcurrentConnections, "LB Virtual Server MaxConcurrentConnections should be same")
		assert.Equal(int64(20), lbVs.MaxNewConnectionRate, "LB Virtual Server MaxNewConnectionRate should be same")
		assert.Equal(int64(3), lbVs.ClientSslProfileBinding.CertificateChainDepth, "LB Virtual Server Client SSL CertificateChainDepth should be same")
		assert.Equal("IGNORE", lbVs.ClientSslProfileBinding.ClientAuth, "LB Virtual Server ClientAuth should be same")
		assert.Equal("IGNORE", lbVs.ServerSslProfileBinding.ServerAuth, "LB Virtual Server ServerAuth should be same")
		assert.Equal(int64(3), lbVs.ServerSslProfileBinding.CertificateChainDepth, "LB Virtual Server Server SSL CertificateChainDepth should be same")
	})

	bpt.Test()
}
