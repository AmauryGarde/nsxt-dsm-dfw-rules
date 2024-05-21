# NSXT DFW Rules for VMware Data Services Manager (DSM)

## Overview

This repository contains Terraform configuration files to create Distributed Firewall (DFW) rules in VMware NSXT for VMware Data Services Manager (DSM). The rules are based on the requirements specified in the [VMware Data Services Manager documentation](https://docs.vmware.com/en/VMware-Data-Services-Manager/2.0/data-services-manager/GUID-vsphere-requirements.html).

## Prerequisites

- Terraform installed on your machine.
- Access to a VMware NSX-T environment with appropriate credentials.
- The necessary permissions to create DFW rules in NSX-T.

## Instructions

### Clone the Repository

To get started, clone this repository to your local machine using the following command:

```sh
git clone https://github.com/AmauryGarde/nsxt-dsm-dfw-rules.git
cd nsxt-dsm-dfw-rules
```

### Fill in the terraform.tfvars File
Before running the Terraform script, you need to provide the necessary variables in the terraform.tfvars file. This file is already included in the repository. Open terraform.tfvars and fill in the required values as shown below:

- **nsx_manager_hostname**: The hostname or IP address of your NSX-T manager.
- **nsx_manager_username**: The username for NSX-T manager authentication.
- **nsx_manager_password**: The password for NSX-T manager authentication.
- **provider_vm_ip**: The IP address of the provider VM.
- **air_gapped_deployment**: Set to true if the deployment is air-gapped, otherwise false.
- **database_segment_ranges**: The IP range(s) of your database segment.
- **app_segment_ranges**: The IP range(s) of your application segment.
- **s3_ips**: A list of IP addresses for S3-compatible storage.
- **end_user_ranges**: A list of IP range(s) for end users.
- **database_client_ranges**: A list of IP range(s) for database clients.

### Run the Terraform Script
Initialize the Terraform workspace:

```sh
terraform init
```

Apply the Terraform configuration to create the DFW rules:

```sh
terraform apply
```

You will be prompted to confirm the creation of the resources. Type yes to proceed.

### Destroy the Resources

If you need to delete the resources created by the Terraform script, run the following command:

```sh
terraform destroy
```

You will be prompted to confirm the deletion of the resources. Type yes to proceed.

## Notes

- Ensure that your NSX-T environment is correctly configured and accessible.
- Review the Terraform script and the terraform.tfvars file to ensure all configurations are appropriate for your environment.
- Modify the Terraform configuration files as necessary to fit your specific requirements.

## Support

For any issues or questions, please open an issue on this repository or contact the repository maintainer.

