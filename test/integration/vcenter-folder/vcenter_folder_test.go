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

package vcenter_folder

import (
	"context"
	"fmt"
	"log"
	"net/url"
	"os"
	"strconv"
	"strings"
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
	"github.com/vmware/govmomi/vim25/types"
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

func vSphereRoleRead(client *govmomi.Client, label string) (int32, error) {
	authorizationManager := object.NewAuthorizationManager(client.Client)
	roleList, err := authorizationManager.RoleList(context.Background())
	if err != nil {
		return 0, fmt.Errorf("error while fetching the role list %s", err)
	}
	var foundRole = types.AuthorizationRole{}
	for _, role := range roleList {
		if role.Info != nil && role.Info.GetDescription() != nil {
			if label == role.Info.GetDescription().Label {
				foundRole = role
			}
		}
	}
	if foundRole.RoleId == 0 {
		return 0, fmt.Errorf("error while fetching the role list %s", err)
	}
	return foundRole.RoleId, nil
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
		vcenter_folder_type := "VirtualMachine"
		permission_user_or_group := "vsphere.local\\\\DCClients"
		permission_is_group := true
		permission_propagate := true
		permission_role := "Monitoring-Role"
		vsphere_folder_id := bpt.GetStringOutput("vcenter_folder_id")
		folders, _ := getFolders(vimClient, "/*")
		authorizationManager := object.NewAuthorizationManager(vimClient.Client)
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
		entityMor := types.ManagedObjectReference{
			Type:  ftype,
			Value: tf_folder.Common.Reference().Value,
		}
		permissionsArr, _ := authorizationManager.RetrieveEntityPermissions(context.Background(), entityMor, false)

		role_id, _ := vSphereRoleRead(vimClient, permission_role)
		actual_user_or_group := permissionsArr[0].Principal
		actual_is_group := permissionsArr[0].Group
		actual_role_id := permissionsArr[0].RoleId
		actual_propagate := permissionsArr[0].Propagate

		assert.Equal(vcenter_folder_name, tf_folder.Name(), "should have the right Folder Name")
		assert.Equal(vcenter_folder_type, ftype, "should have the right Folder Type")
		assert.Equal(permission_is_group, actual_is_group, "should have the right Permssion Paramter Group")
		assert.Equal(permission_propagate, actual_propagate, "should have the right Permssion Paramter Propogate")
		assert.Equal(strings.ToLower(permission_user_or_group), strings.ToLower(actual_user_or_group), "should have the right Permssion Group")
		assert.Equal(role_id, actual_role_id, "should have the right Permssion Role")
	})

	bpt.Test()
}
