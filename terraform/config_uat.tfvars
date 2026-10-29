region        = "eu-west-2"
environment   = "uat"
cpu           = 1024
memory        = 2048
service_count = 1
min_capacity  = 1
max_capacity  = 2

enable_alarms = false

# The common stack creates these values again on each UAT start (RFC 002 in
# trade-tariff-platform-aws-terraform, "Generated values").
generated_secrets = {
  REDIS_URL = "valkey-frontend-connection-string"
}
