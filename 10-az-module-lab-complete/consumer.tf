# Call the Scalable Web module with
# a VM count of 2,
# an app name of your choice,
# an app prefix of your choice.
module "scalable_web" {
    source = "./modules/scalable-web"
    app_name = "Circus Show"
    vm_count = 2
    app_prefix = "circ"
}

# Output the public IP of the load balancer
output "app_ip" {
    value = module.scalable_web.lb_public_ip
}

# Output the app code
output "app_code" {
    value = module.scalable_web.app_code
}