# VMWare vCenter T1 Zone example
This example shows an example of the T1 zone module, which implements T1 router and it related resources : 
- a list of NSXT segments attached to it
- a List of N/S Firewall rules applied to it


## Usage

* Generate a gcve.auto.tfvars with the NSXT and Vcenter credentials  
    * Use the set_credentals.sh script to generate it (please make sure to update the variables PRIVATE_CLOUD,
ZONE and PROJECT directly in the script)  
    * Write it manually following the template gcve.credentials.auto.tfvars.template  
* Update the file net-zones.tf with your values, which should tipically include
    * T1 logical router names  
    * Segment names and IP ranges (Please use the format $VALUE_OF_GATEWAY/VALUE_OF_MASK)  
    * North/South firewall rules
* Run the terraform commands (init, plan, apply) 