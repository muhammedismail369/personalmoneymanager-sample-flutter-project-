import 'package:flutter/material.dart';
import 'package:money_manager_app/db/category/category_db.dart';
import 'package:money_manager_app/db/transaction/transaction_db.dart';
import 'package:money_manager_app/models/category/category_model.dart';
import 'package:money_manager_app/models/transactions/transaction_model.dart';

class ScreenAddTransactions extends StatefulWidget {
  const ScreenAddTransactions({Key? key}) : super(key: key);

  static const routeName = 'add-transactions';

  @override
  State<ScreenAddTransactions> createState() => _ScreenAddTransactionsState();
}

class _ScreenAddTransactionsState extends State<ScreenAddTransactions> {
  DateTime? _selectedDate;
  CategoryType? _selectedCategoryType;
  CategoryModel? _selectedCategoryModel;

  String? _categoryID;

  final _purposeTextEditingController = TextEditingController();
  final _amountTextEditingController = TextEditingController();

  @override
  void initState() {
    _selectedCategoryType = CategoryType.income;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        //purpose
        children: [
          TextFormField(
            controller: _purposeTextEditingController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: 'Purpose',
            ),
          ),

          //amount
          TextFormField(
            controller: _amountTextEditingController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Amount',
            ),
          ),

          //calender

          TextButton.icon(
            onPressed: () async {
              final _selectedDateTemp = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now(),
              );
              if (_selectedDateTemp == null) {
                return;
              } else {
                print(_selectedDateTemp.toString());
                setState(() {
                  _selectedDate = _selectedDateTemp;
                });
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(_selectedDate == null
                ? 'Selected Date'
                : _selectedDate.toString()),
          ),
          //category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Radio(
                    value: CategoryType.income,
                    groupValue: _selectedCategoryType,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategoryType = CategoryType.income;
                        _categoryID = null;
                      });
                    },
                  ),
                  Text('Income')
                ],
              ),
              Row(
                children: [
                  Radio(
                    value: CategoryType.expense,
                    groupValue: _selectedCategoryType,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategoryType = CategoryType.expense;
                        _categoryID = null;
                      });
                    },
                  ),
                  Text('Expense')
                ],
              ),
            ],
          ),
          //categoryType
          DropdownButton(
            hint: const Text('Select Category'),
            value: _categoryID,
            items: (_selectedCategoryType == CategoryType.income
                    ? CategoryDB().incomeCategoryListListener
                    : CategoryDB().expenseCategoryListListener)
                .value
                .map((e) {
              return DropdownMenuItem(
                value: e.id,
                child: Text(e.name),
                onTap: () {
                  _selectedCategoryModel = e;
                },
              );
            }).toList(),
            onChanged: (selectedValue) {
              print(selectedValue);
              setState(() {
                _categoryID = selectedValue as String?;
              });
            },
          ),
          //submit
          ElevatedButton(
            onPressed: () {
              addTransaction();
            },
            child: Text('Submit'),
          )
        ],
      ),
    )));
  }

  Future<void> addTransaction() async {
    final _purposeText = _purposeTextEditingController.text;
    final _amountText = _amountTextEditingController.text;

    if (_purposeText.isEmpty) {
      return;
    }
    if (_amountText.isEmpty) {
      return;
    }
    // if (_categoryID == null) {
    //   return;
    // }
    if (_selectedDate == null) {
      return;
    }

    final _parsedAmount = double.tryParse(_amountText);
    if (_parsedAmount == null) {
      return;
    }

    if (_selectedCategoryModel == null) {
      return;
    }
    //_selectedDate;
    //_selectedCategoryType
    //CategoryType

    final _model = TransactionModel(
      purpose: _purposeText,
      amount: _parsedAmount,
      date: _selectedDate!,
      type: _selectedCategoryType!,
      category: _selectedCategoryModel!,
    );

    await TransactionDB.instance.addTransactions(_model);
    Navigator.of(context).pop();
    TransactionDB.instance.refresh();
  }
}
