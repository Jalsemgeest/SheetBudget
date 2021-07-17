class InputForm {

  String _month;
  String _text;
  String _value;
  bool _isExpense;

  InputForm(this._month, this._text, this._value, this._isExpense);

  // Method to make GET parameters.
  String toParams() =>
      "?q=input&month=$_month&text=$_text&value=$_value&isExpense=$_isExpense";
}