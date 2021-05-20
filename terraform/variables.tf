variable "cf_api" { type = string }
variable "cf_username" { type = string }
variable "cf_password" { type = string }
variable "cf_org" { type = string }

variable "dev-managers" { type = list(string) }
variable "dev-developers" { type = list(string) }
variable "dev-auditors" { type = list(string) }
