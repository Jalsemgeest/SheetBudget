import 'dart:convert' as convert;
import 'package:budget_app/config.dart';
import 'package:budget_app/model/input_form.dart';
import 'package:budget_app/model/totals_form.dart';
import 'package:http/http.dart' as http;


class FormController {
  // Callback function to give response of status of current request.
  final void Function(Object) callback;

  // Google App Script Web URL
  static String url = properties['URL'];

  static const STATUS_SUCCESS = "SUCCESS";

  FormController(this.callback);

  void submitForm(InputForm inputForm) async{
    try{
      await http.get(Uri.parse(url + inputForm.toParams())).then(
          (response){
            callback(convert.jsonDecode(response.body));
          });
    } catch(e){
      print(e);
    }
  }

  void getTotals(TotalsForm totalsForm) async {
    try {
      await http.get(Uri.parse(url + totalsForm.toParams())).then(
        (response) {
          callback(convert.jsonDecode(response.body));
        });
    } catch (e) {
      print(e);
    }
  }
}
