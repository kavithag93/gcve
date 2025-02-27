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

package nsxt_lb_svc

import (
	"os"
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	api "github.com/vmware/go-vmware-nsxt"
	"github.com/vmware/go-vmware-nsxt/loadbalancer"
)

func TestNsxtLoadBalancerSvc(t *testing.T) {
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
		load_balancer_service_path := bpt.GetStringOutput("load_balancer_service_path")
		lb_svcs, _, err1 := nsxClient.ServicesApi.ListLoadBalancerServices(nsxClient.Context, nil)
		if err1 != nil {
			panic(err1)
		}
		var lbSvc loadbalancer.LbService
		for _, v := range lb_svcs.Results {
			path := v.Tags[0].Tag
			if path == load_balancer_service_path {
				lbSvc = v
			}
		}
		assert.Equal("cft-test-lb", lbSvc.DisplayName, "LB Service Display Name should be same")
		assert.Equal(true, lbSvc.Enabled, "LB Service  should be enabled")
	})

	bpt.Test()
}
