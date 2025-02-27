#!/bin/bash
GCP_PROJECT="$1"
GOOGLE_APPLICATION_CREDENTIALS="$2"

echo "::add-mask::$GCP_PROJECT"
echo "::add-mask::$GOOGLE_APPLICATION_CREDENTIALS"
export GCP_PROJECT=$GCP_PROJECT
export CLOUDSDK_PROJECT=$GCP_PROJECT
export CLOUDSDK_CORE_PROJECT=$GCP_PROJECT
export GCLOUD_PROJECT=$GCP_PROJECT
export GOOGLE_CLOUD_PROJECT=$GCP_PROJECT
export GOOGLE_APPLICATION_CREDENTIALS=$GOOGLE_APPLICATION_CREDENTIALS
gcloud auth login --cred-file=$GOOGLE_APPLICATION_CREDENTIALS

# Fetch Vshpere Secrets
VSPHERE_SERVER=$(gcloud secrets  versions  access latest --secret $4)
VSPHERE_USER=$(gcloud secrets  versions  access latest --secret $5)
VSPHERE_PASSWORD=$(gcloud secrets  versions  access latest --secret $6)

# Fetch NSXT Secrets
NSXT_MANAGER_HOST=$(gcloud secrets  versions  access latest --secret $7)
NSXT_USERNAME=$(gcloud secrets  versions  access latest --secret $8)
NSXT_PASSWORD=$(gcloud secrets  versions  access latest --secret $9)

echo "::add-mask::$VSPHERE_SERVER"
echo "::add-mask::$VSPHERE_USER"
echo "::add-mask::$VSPHERE_PASSWORD"

echo "::add-mask::$NSXT_MANAGER_HOST"
echo "::add-mask::$NSXT_USERNAME"
echo "::add-mask::$NSXT_PASSWORD"

echo "VSPHERE_SERVER=${VSPHERE_SERVER}" >> $GITHUB_ENV
echo "VSPHERE_USER=${VSPHERE_USER}" >> $GITHUB_ENV
echo "VSPHERE_PASSWORD=${VSPHERE_PASSWORD}" >> $GITHUB_ENV
echo "GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS}" >> $GITHUB_ENV
echo "GCP_PROJECT=${GCP_PROJECT}" >> $GITHUB_ENV
echo "CLOUDSDK_PROJECT=${GCP_PROJECT}" >> $GITHUB_ENV
echo "CLOUDSDK_CORE_PROJECT=${GCP_PROJECT}" >> $GITHUB_ENV
echo "GCLOUD_PROJECT=${GCP_PROJECT}" >> $GITHUB_ENV
echo "GOOGLE_CLOUD_PROJECT=${GCP_PROJECT}" >> $GITHUB_ENV
echo "VSPHERE_ALLOW_UNVERIFIED_SSL=true" >> $GITHUB_ENV
echo "NSXT_MANAGER_HOST=${NSXT_MANAGER_HOST}" >> $GITHUB_ENV
echo "NSXT_USERNAME=${NSXT_USERNAME}" >> $GITHUB_ENV
echo "NSXT_PASSWORD=${NSXT_PASSWORD}" >> $GITHUB_ENV
echo "NSXT_ALLOW_UNVERIFIED_SSL=true" >> $GITHUB_ENV
