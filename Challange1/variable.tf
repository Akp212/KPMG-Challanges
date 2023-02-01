variable "resource_group_name" {
    type = string
}
variable "location" {
    type = string
}
variable "virtual_network_name" {
  type = string
}
variable "web_subnet_name" {
  type = string
}
variable "app_subnet_name" {
  type = string
}
variable "db_subnet_name" {
  type = string
}
variable "web_network_interface_name" {
  type = string
}
variable "app_network_interface_name" {
  type = string
}
variable "web_virtual_machine_name" {
  type = string
}
variable "app_virtual_machine_name" {
  type = string
}
variable "primary_database" {
    type = string
}
variable "primary_database_version" {
    type = string
}
variable "web_nsg_name" {
   type = string
}
variable "app_nsg_name" {
   type = string
}
variable "db_nsg_name" {
   type = string
}
