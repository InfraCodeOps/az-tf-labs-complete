variable "storage_prefix" {
  description = "Input must be 4-8 characters long and only letters"
  type        = string

  validation {
    # The expression assigned to condition needs to be on one line
    condition = length(var.storage_prefix) >= 4 && length(var.storage_prefix) <= 8
    error_message = "Input must be 4-8 characters long."
  }

  # validation to ensure only lower case letters are allowed:
  validation {
    condition     = can(regex("^[a-z]*$", var.storage_prefix))
    error_message = "Input must be only lower case letters."
  }
}