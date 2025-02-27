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

package nsxt_distributed_firewall_manager

import (
	"os"
	"strconv"
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	api "github.com/vmware/go-vmware-nsxt"
)

func TestNsxtDistributedFirewallManager(t *testing.T) {
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

		// test Firewall Section
		fw_section_id := bpt.GetStringOutput("nsxt_firewall_section_id")

		fwSectionRuleList, _, err := nsxClient.ServicesApi.GetSectionWithRulesListWithRules(nsxClient.Context, fw_section_id)
		if err != nil {
			panic(err)
		}
		assert.Equal("GCVE IaC Foundations Section", fwSectionRuleList.FirewallSection.DisplayName, "FW Section Display Name should be same")
		assert.Equal("LAYER3", fwSectionRuleList.FirewallSection.SectionType, "FW Section type should be same")
		assert.Equal(int64(2), fwSectionRuleList.FirewallSection.RuleCount, "FW Section RuleCount should be 2")

		assert.Containsf("gcve-iac-rule1", fwSectionRuleList.Rules[0].DisplayName, "LB Pool SnatTranslation Type should be same")

		// test Firewall IpSets
		out := bpt.GetStringOutput("nsxt_firewall_ipsets_ids")
		fw_ipsets := make(map[string]string)

		// prepare map object from string output
		out1 := strings.Fields(strings.Trim(strings.Trim(out, "map["), "]"))
		for _, s := range out1 {
			temp := strings.Split(s, ":")
			fw_ipsets[temp[0]] = temp[1]
		}

		testdata := map[string][]string{
			"ip_set_source_1": {"10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"},
			"ip_set_source_2": {"10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"},
			"ip_set_dest_1":   {"10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"},
		}

		for k, v := range fw_ipsets {
			ipSet, _, err := nsxClient.GroupingObjectsApi.ReadIPSet(nsxClient.Context, v)
			if err != nil {
				panic(err)
			}
			assert.Equal(k, ipSet.DisplayName, "FW Section type should be same")
			assert.ElementsMatch(testdata[k], ipSet.IpAddresses, "Ip Set should contain the Ip CIDR")

		}

		// test Firewall service
		tempOut := bpt.GetStringOutput("nsxt_firewall_service_ids")
		fw_svc := make(map[string]string)

		// prepare map object from string output
		out2 := strings.Fields(strings.Trim(strings.Trim(tempOut, "map["), "]"))
		for _, s := range out2 {
			temp := strings.Split(s, ":")
			fw_svc[temp[0]] = temp[1]
		}

		testdataSvc := map[string]map[string][]string{
			"ex-l4-service-1": {
				"protocol":          []string{"TCP"},
				"destination_ports": []string{"73", "8080", "81"},
				"source_ports":      []string{"80"},
			},
			"ex-l4-service-2": {
				"protocol":          []string{"TCP"},
				"destination_ports": []string{"8888"},
				"source_ports":      []string{"1234"},
			},
		}

		for k, v := range fw_svc {
			svc, _, err := nsxClient.GroupingObjectsApi.ReadL4PortSetNSService(nsxClient.Context, v)
			if err != nil {
				panic(err)
			}
			assert.Equal(k, svc.DisplayName, "FW Service display name should be same")
			assert.Contains(testdataSvc[k]["protocol"], svc.NsserviceElement.L4Protocol, "FW Service L4 protocol should be same")
			assert.ElementsMatch(testdataSvc[k]["destination_ports"], svc.NsserviceElement.DestinationPorts, "FW Service L4 destination ports should match")
			assert.ElementsMatch(testdataSvc[k]["source_ports"], svc.NsserviceElement.SourcePorts, "FW Service L4 source ports should match")
		}
	})

	bpt.Test()
}
