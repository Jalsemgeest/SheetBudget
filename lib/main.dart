import 'dart:html';

import 'package:budget_app/model/totals_form.dart';
import 'package:flutter/material.dart';
import 'package:budget_app/controller.dart';
import 'package:budget_app/model/input_form.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheets Budget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //

  static const MONTHS = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  var _currentlySelectedMonth = MONTHS[DateTime.now().month - 1];
  var _isExpense = true;
  var _monthlyExpenses = 0;
  var _monthlyIncome = 0;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
  TextEditingController textController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();

  void _submitForm() {

    if(_formKey.currentState!.validate()){
      InputForm feedbackForm = InputForm(
          _currentlySelectedMonth,
          textController.text,
          valueController.text,
          _isExpense,
      );

      FormController formController = FormController((dynamic response){
        print("Response: $response");
        if(response['status'] == FormController.STATUS_SUCCESS){
          //
          _showSnackbar(_isExpense ? "Expense Added" : "Income Added");
          setState(() {
            if (_isExpense && _monthlyExpenses != 0) {
              _monthlyExpenses += int.parse(valueController.text);
            } else if (!_isExpense && _monthlyIncome != 0) {
              _monthlyIncome += int.parse(valueController.text);
            }
          });
        } else {
          _showSnackbar("Error Occurred!");
        }
      });

      _showSnackbar("Submitting Feedback");

      // Submit 'feedbackForm' and save it in Google Sheet

      formController.submitForm(feedbackForm);
    }
  }

  void _getTotals() {
    if (MONTHS.contains(_currentlySelectedMonth)) {
      TotalsForm totalsForm = TotalsForm(_currentlySelectedMonth);

      FormController formController = FormController((dynamic response) {
      
        print("Response $response");
        setState(() {
          _monthlyIncome = response['income'];
          _monthlyExpenses = response['expenses'];
        });
        // if(response == FormController.STATUS_SUCCESS){
        //   //
        //   _showSnackbar("Feedback Submitted");
        // } else {
        //   _showSnackbar("Error Occurred!");
        // }
      });

      formController.getTotals(totalsForm);
    }
  }

  // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    _scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:  _scaffoldKey,
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 50,horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        hint: new Text("Select Date to Add To"),
                        value: _currentlySelectedMonth,
                        onChanged: (newValue) {
                          setState(() {
                            _currentlySelectedMonth = newValue!;
                          });
                          print(newValue);
                        },
                        isDense: true,
                        items: MONTHS.map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e))
                        ).toList(),
                      )
                    ),
                    TextFormField(
                      controller: textController,
                      validator: (value){
                        if(value!.isEmpty){
                          return "Enter a description for your expense/income";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: "Description"
                      ),
                    ),
                    TextFormField(
                      controller: valueController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                          labelText: "Expense/Income Value"
                      ),
                    ),
                    SwitchListTile(
                      title: Text("Expense/Income"),
                      onChanged: (bool newValue) {
                        setState(() {
                          _isExpense = newValue;
                        });
                        print(newValue);
                      },
                      value: _isExpense,
                    ),
                    RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: _submitForm,
                      child: _isExpense ? Text('Submit Expense') : Text('Submit Income'),
                    ),
                    RaisedButton(
                      color: Colors.blue,
                      textColor: Colors.white,
                      onPressed: _getTotals,
                      child: Text("Get Totals For Month"),
                      ),
                      Row(children: [
                        Column(children: [
                          Text("Expenses"),
                          Text("\$$_monthlyExpenses"),
                        ],),
                        Column(children: [
                          Text("Income"),
                          Text("\$$_monthlyIncome"),
                        ],)
                      ],)
                      ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}