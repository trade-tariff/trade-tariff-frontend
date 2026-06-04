region        = "eu-west-2"
environment   = "production"
cpu           = 2048
memory        = 4096
service_count = 3
min_capacity  = 3
max_capacity  = 16

# Temporarily pinned autoscaling cooldown values in Production to preserve existing behaviour while testing changes in dev and staging
scale_in_cooldown  = 0
scale_out_cooldown = 0

enable_observability_alerts = true
