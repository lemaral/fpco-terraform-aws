# AWS Managed NAT Gateways
resource "aws_eip" "nat" {
  count = "${var.nat_count}"
  vpc   = true
}

resource "aws_nat_gateway" "nat" {
  count         = "${var.nat_count}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
  subnet_id     = "${var.public_subnet_ids[count.index]}"
}


# Route tables. One per NAT gateway.
resource "aws_route_table" "private" {
  count  = "${var.nat_count}"
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat.*.id, count.index)}"
  }

  tags = "${merge(map("Name", "${var.name_prefix}-private-${format("%02d", count.index)}"), "${var.extra_tags}")}"
}

resource "aws_route_table_association" "private-rta" {
  count          = "${var.nat_count}"
  subnet_id      = "${var.private_subnet_ids[count.index]}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

