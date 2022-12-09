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
	"github.com/vmware/govmomi/vim25/mo"
	"github.com/vmware/govmomi/vim25/soap"
)

const DefaultAPITimeout = time.Minute * 5

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

func FromAbsolutePath(client *govmomi.Client, path string) (*object.Folder, error) {
	finder := find.NewFinder(client.Client, false)
	ctx, cancel := context.WithTimeout(context.Background(), DefaultAPITimeout)
	defer cancel()
	folder, err := finder.Folder(ctx, path)
	if err != nil {
		return nil, err
	}
	return folder, nil
}

func getFolders(client *govmomi.Client, path string) ([]*object.Folder, error) {
	ctx := context.TODO()
	var folders []*object.Folder
	finder := find.NewFinder(client.Client, false)
	es, err := finder.ManagedObjectListChildren(ctx, path, "folder")
	if err != nil {
		return nil, err
	}
	for _, id := range es {
		switch {
		case id.Object.Reference().Type == "Folder":
			f, _ := FromAbsolutePath(client, id.Path)
			folders = append(folders, f)
			newFolders, err := getFolders(client, id.Path)
			if err != nil {
				return nil, err
			}
			folders = append(folders, newFolders...)
		default:
			continue
		}
	}
	return folders, nil
}

func Properties(folder *object.Folder) (*mo.Folder, error) {
	ctx, cancel := context.WithTimeout(context.Background(), DefaultAPITimeout)
	defer cancel()
	var props mo.Folder
	if err := folder.Properties(ctx, folder.Reference(), nil, &props); err != nil {
		return nil, err
	}
	return &props, nil
}

func TestVcenterFolder(t *testing.T) {
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

	bpt.DefineVerify(func(assert *assert.Assertions) {

		bpt.DefaultVerify(assert)
		vcenter_folder_name := "folder-cft-test"
		vsphere_folder_id := bpt.GetStringOutput("vcenter_folder_id")
		folders, _ := getFolders(vimClient, "/*")
		var tf_folder *object.Folder
		for _, v := range folders {
			if v.Common.Reference().Value == vsphere_folder_id {
				tf_folder = v
			}
		}
		props, _ := Properties(tf_folder)
		var ftype string
		if props.ChildType[0] != "Folder" {
			ftype = props.ChildType[0]
		} else {
			ftype = props.ChildType[1]
		}
		assert.Equal(vcenter_folder_name, tf_folder.Name(), "should have the right Folder Name")
		assert.Equal(ftype, "VirtualMachine", "should have the right Folder Type")
	})

	bpt.Test()
}
