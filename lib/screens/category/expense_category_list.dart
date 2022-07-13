import 'package:flutter/material.dart';
import 'package:money_manager_app/db/category/category_db.dart';
import '../../models/category/category_model.dart';

class ExpenseCategoryList extends StatelessWidget {
  const ExpenseCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: CategoryDB().expenseCategoryListListener,
        builder: (BuildContext ctx, List<CategoryModel> newList, Widget? _) {
          return ListView.separated(
            itemCount: newList.length,
            separatorBuilder: (ctx, index) {
              return const SizedBox(height: 10);
            },
            itemBuilder: (ctx, index) {
              final category = newList[index];
              return Card(
                child: ListTile(
                  title: Text(category.name),
                  trailing: IconButton(
                    onPressed: () {
                      CategoryDB.instance.deleteCategory(category.id);
                    },
                    icon: const Icon(Icons.delete),
                  ),
                ),
              );
            },
          );
        });
  }
}
