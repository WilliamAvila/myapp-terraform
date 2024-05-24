resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.app_name}-${terraform.workspace}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        width  = 18
        height = 6

        properties = {
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", "${aws_ecs_service.my_service.name}", "ClusterName", "${aws_ecs_cluster.my_cluster.name}", { color = "#d62728", stat = "Maximum" }],
            [".", "MemoryUtilization", ".", ".", ".", ".", { yAxis = "right", color = "#1f77b4", stat = "Maximum" }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = "us-east-1"
          title   = "EC2 Instance CPU"
          region  = var.region,
          annotations = {
            horizontal = [
              {
                color = "#ff9896",
                label = "100% CPU",
                value = 100
              },
              {
                color = "#9edae5",
                label = "100% Memory",
                value = 100,
                yAxis = "right"
              },
            ]
          }
          yAxis = {
            left = {
              min = 0
            }
            right = {
              min = 0
            }
          }
          title  = "${var.app_name}-${terraform.workspace}-CW"
          period = 300
        }
      }
    ]
  })
  depends_on = [aws_ecs_service.my_service]
}