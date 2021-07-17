class TotalsForm {

  String _month;
  TotalsForm(this._month);

  // Method to make GET parameters.
  String toParams() =>
      "?q=totals&month=$_month";
}