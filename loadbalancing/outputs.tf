output "aws_lb_target_group" {
  value = aws_lb_target_group.mtc_tg
}

output "aws_lb_listener" {
    value = aws_lb_listener.mtc_lb_listener
}

output "aws_lb" {
    value = aws_lb.mtc_lb
}