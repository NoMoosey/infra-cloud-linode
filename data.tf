# data "linode_instance_types" "specific-types" {
#   filter {
#     name = "vcpus"
#     values = [2]
#   }
#   filter {
#     name = "memory"
#     values = [4096]
#   }
# }

# output "instances" {
#     value = data.linode_instance_types.specific-types
# }