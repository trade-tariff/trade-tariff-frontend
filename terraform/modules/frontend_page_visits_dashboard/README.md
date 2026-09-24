<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_dashboard.page_visits](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment containing the frontend request logs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region containing the frontend request logs. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dashboard_name"></a> [dashboard\_name](#output\_dashboard\_name) | Frontend page visits dashboard name. |
| <a name="output_dashboard_url"></a> [dashboard\_url](#output\_dashboard\_url) | Frontend page visits dashboard URL. |
<!-- END_TF_DOCS -->
