enum LeaseType {
  borrow("BORROW"),
  lend("LEND");

  final String display;
  const LeaseType(this.display);

  @override
  String toString() => "The $name leaseType is $display F.";
}
