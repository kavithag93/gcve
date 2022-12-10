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

package vcenter_resource_pool

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
	"github.com/vmware/govmomi"
	"github.com/vmware/govmomi/find"
	"github.com/vmware/govmomi/object"
	"github.com/vmware/govmomi/session"
	"github.com/vmware/govmomi/vim25"
	"github.com/vmware/govmomi/vim25/soap"
	"github.com/vmware/govmomi/vim25/types"
)

const DefaultAPITimeout = time.Minute * 5

// Client is the client connection manager for the vSphere provider. It
// holds the connections to the various API endpoints we need to interface
// with, such as the VMODL API through govmomi, and the REST SDK through
// alternate libraries.
type Client struct {
	// The VIM/govmomi client.
	vimClient *govmomi.Client
}

type Config struct {
	InsecureFlag  bool
	User          string
	Password      string
	VSphereServer string
	KeepAlive     int
}

// NewConfig returns a new Config from a supplied ResourceData.
func NewConfig(user, password, server string, insecure bool) (*Config, error) {

	c := &Config{
		User:          user,
		Password:      password,
		InsecureFlag:  insecure,
		VSphereServer: server,
	}

	return c, nil
}

// vimURL returns a URL to pass to the VIM SOAP client.
func (c *Config) vimURL() (*url.URL, error) {
	u, err := url.Parse("https://" + c.VSphereServer + "/sdk")
	if err != nil {
		return nil, fmt.Errorf("Error parse url: %s", err)
	}

	u.User = url.UserPassword(c.User, c.Password)

	return u, nil
}

// Client returns a new client for accessing VMWare vSphere.
func (c *Config) Client() (*Client, error) {
	client := new(Client)

	u, err := c.vimURL()
	if err != nil {
		return nil, fmt.Errorf("Error generating SOAP endpoint url: %s", err)
	}

	// Set up the VIM/govmomi client connection, or load a previous session
	client.vimClient, err = c.SavedVimSessionOrNew(u)
	if err != nil {
		return nil, err
	}

	log.Printf("[DEBUG] VMWare vSphere Client configured for URL: %s", c.VSphereServer)
	return client, nil
}

// SavedVimSessionOrNew either loads a saved SOAP session from disk, or creates
// a new one.
func (c *Config) SavedVimSessionOrNew(u *url.URL) (*govmomi.Client, error) {
	ctx, cancel := context.WithTimeout(context.Background(), DefaultAPITimeout)
	defer cancel()
	client, err := newClientWithKeepAlive(ctx, u, c.InsecureFlag, c.KeepAlive)
	if err != nil {
		return nil, fmt.Errorf("error setting up new vSphere SOAP client: %s", err)
	}
	log.Println("[DEBUG] SOAP API session creation successful")

	return client, nil
}

func newClientWithKeepAlive(ctx context.Context, u *url.URL, insecure bool, keepAlive int) (*govmomi.Client, error) {
	soapClient := soap.NewClient(u, insecure)
	vimClient, err := vim25.NewClient(ctx, soapClient)
	if err != nil {
		return nil, err
	}

	c := &govmomi.Client{
		Client:         vimClient,
		SessionManager: session.NewManager(vimClient),
	}

	k := session.KeepAlive(c.Client.RoundTripper, time.Duration(keepAlive)*time.Minute)
	c.Client.RoundTripper = k

	// Only login if the URL contains user information.
	if u.User != nil {
		err = c.Login(ctx, u.User)
		if err != nil {
			return nil, err
		}
	}

	return c, nil
}

func FromID(client *govmomi.Client, id string) (*object.ResourcePool, error) {
	log.Printf("[DEBUG] Locating resource pool with ID %s", id)
	finder := find.NewFinder(client.Client, false)

	ref := types.ManagedObjectReference{
		Type:  "ResourcePool",
		Value: id,
	}

	ctx, cancel := context.WithTimeout(context.Background(), DefaultAPITimeout)
	defer cancel()
	obj, err := finder.ObjectReference(ctx, ref)
	if err != nil {
		return nil, err
	}
	log.Printf("[DEBUG] Resource pool found: %s", obj.Reference().Value)
	return obj.(*object.ResourcePool), nil
}

func resourcepoolsByPath(client *govmomi.Client, path string) ([]*object.ResourcePool, error) {
	ctx := context.TODO()
	var rps []*object.ResourcePool
	finder := find.NewFinder(client.Client, false)
	es, err := finder.ManagedObjectListChildren(ctx, path+"/*", "pool", "folder")
	if err != nil {
		return nil, err
	}
	for _, id := range es {
		if id.Object.Reference().Type == "ResourcePool" {
			ds, err := FromID(client, id.Object.Reference().Value)
			if err != nil {
				return nil, err
			}
			rps = append(rps, ds)
		}
		if id.Object.Reference().Type == "Folder" || id.Object.Reference().Type == "ClusterComputeResource" || id.Object.Reference().Type == "ResourcePool" {
			newRPs, err := resourcepoolsByPath(client, id.Path)
			if err != nil {
				return nil, err
			}
			rps = append(rps, newRPs...)
		}
	}
	return rps, nil
}

func TestVcenterResourcePool(t *testing.T) {
	insecure, _ := strconv.ParseBool(os.Getenv("VSPHERE_ALLOW_UNVERIFIED_SSL"))
	username := os.Getenv("VSPHERE_USER")
	password := os.Getenv("VSPHERE_PASSWORD")
	host := os.Getenv("VSPHERE_SERVER")

	c, err := NewConfig(username, password, host, insecure)
	if err != nil {
		fmt.Errorf("%s", err)
	}
	vclient, _ := c.Client()
	vimClient := vclient.vimClient

	bpt := tft.NewTFBlueprintTest(t)
	var resource_pool_id string
	bpt.DefineVerify(func(assert *assert.Assertions) {
		bpt.DefaultVerify(assert)
		resource_pool_name := "terraform-resource-pool-cft-test"
		vsphere_resource_pool_id := bpt.GetStringOutput("vsphere_resource_pool_id")
		resoucePools, _ := resourcepoolsByPath(vimClient, "")
		for _, v := range resoucePools {
			if v.Name() == resource_pool_name {
				resource_pool_id = v.Reference().Value
			}

		}
		assert.Equal(vsphere_resource_pool_id, resource_pool_id, "should have the right Resource Pool Name")
	})

	bpt.Test()
}
