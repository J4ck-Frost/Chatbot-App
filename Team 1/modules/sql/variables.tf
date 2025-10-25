variable "instance_name" {
	description = "The name of the Cloud SQL instance."
	type        = string
}

variable "project_id" {
	description = "The GCP project ID."
	type        = string
}

variable "database_version" {
	description = "The database version to use."
	type        = string
	default     = "POSTGRES_13"
}

variable "region" {
	description = "The region for the Cloud SQL instance."
	type        = string
}

variable "tier" {
	description = "The machine type for the Cloud SQL instance."
	type        = string
	default     = "db-f1-micro"
}

variable "disk_size" {
	description = "The size of the disk in GB."
	type        = number
	default     = 10
}

variable "disk_type" {
	description = "The type of disk (PD_SSD, PD_HDD)."
	type        = string
	default     = "PD_SSD"
}

variable "db_name" {
	description = "The name of the default database."
	type        = string
}

variable "db_user" {
	description = "The name of the default user."
	type        = string
}

variable "db_password" {
	description = "The password for the default user."
	type        = string
	sensitive   = true
}

variable "vpc_network_id" {
	description = "The ID of the VPC network for private IP"
	type        = string
}
