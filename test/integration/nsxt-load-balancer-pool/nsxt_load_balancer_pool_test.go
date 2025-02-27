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

package nsxt_lb_pool

import (
	"os"
	"strconv"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	api "github.com/vmware/go-vmware-nsxt"
	"github.com/vmware/go-vmware-nsxt/loadbalancer"
)

func TestNsxtLoadBalancerPool(t *testing.T) {
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
		lb_pool_path := bpt.GetStringOutput("lb_pool_path")
		lb_pools, _, err1 := nsxClient.ServicesApi.ListLoadBalancerPools(nsxClient.Context, nil)
		if err1 != nil {
			panic(err1)
		}
		var lbPool loadbalancer.LbPool
		for _, v := range lb_pools.Results {
			path := v.Tags[0].Tag
			if path == lb_pool_path {
				lbPool = v
			}
		}
		assert.Equal("cft_test_lb_pool", lbPool.DisplayName, "LB Pool Display Name should be same")
		assert.Equal("IP_HASH", lbPool.Algorithm, "LB Pool Algorithm should be same")
		assert.Equal(int64(2), lbPool.MinActiveMembers, "LB Pool MinActiveMembers should be same")
		assert.Equal("LbSnatAutoMap", lbPool.SnatTranslation.Type_, "LB Pool SnatTranslation Type should be same")
	})

	bpt.Test()
}
