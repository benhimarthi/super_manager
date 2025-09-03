import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/authentication/domain/entities/user.dart';
import 'package:super_manager/features/authentication/presentation/pages/user_management_screen/item.more.informations.view.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';
import '../../../../action_history/domain/entities/action.history.dart';
import '../../../../action_history/presentation/cubit/action.history.cubit.dart';
import '../../../../action_history/presentation/cubit/action.history.state.dart';
import '../../../../widge_manipulator/cubit/widget.manipulator.state.dart';

class UserActivitiesManager extends StatefulWidget {
  final User user;
  const UserActivitiesManager({super.key, required this.user});

  @override
  State<UserActivitiesManager> createState() => _UserActivitiesManagerState();
}

class _UserActivitiesManagerState extends State<UserActivitiesManager> {
  late String selectedCategory;
  late String module;
  late String currentHist;
  late List<ActionHistory> myHistory;
  late List<ActionHistory> byModule;

  @override
  void initState() {
    super.initState();
    selectedCategory = "product";
    module = "product-management";
    currentHist = "";
    myHistory = [];
    byModule = [];
    context.read<ActionHistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                BlocConsumer<WidgetManipulatorCubit, WidgetManipulatorState>(
                  listener: (context, state) {
                    if (state is EmitRandomElementSuccessfully) {
                      try {
                        var datas = state.element as Map<String, dynamic>;
                        if (datas['id'] == "select_activities_category") {
                          setState(() {
                            selectedCategory = datas['category'];
                            switch (selectedCategory) {
                              case "product":
                                module = "product-management";
                                break;
                              case "stock":
                                module = "inventory-management";
                                break;
                              case "account":
                                module = "authentication-service";
                                break;
                              case "sales":
                                module = "sale-management";
                                break;
                            }
                            byModule = myHistory
                                .where((x) => x.module == module)
                                .toList();
                          });
                        }
                        if (datas['id'] == "show_history_detail") {
                          setState(() {
                            currentHist = currentHist == datas['element_id']
                                ? ""
                                : datas['element_id'];
                          });
                        }
                        // ignore: empty_catches
                      } catch (e) {}
                    }
                  },
                  builder: (context, state) {
                    return SizedBox();
                  },
                ),
                CircleAvatar(
                  radius: 45,
                  //backgroundImage: FileImage(file),
                  child: Text(
                    widget.user.name[0],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      widget.user.email,
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 1,
              color: const Color.fromARGB(34, 255, 255, 255),
            ),
            SizedBox(height: 10),
            Text(
              "User activities",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              //color: Colors.blue,
              child: ListView(
                scrollDirection: Axis.horizontal,

                children: [
                  filterOption("Account", selectedCategory == "account", () {
                    context.read<WidgetManipulatorCubit>().emitRandomElement({
                      "id": "select_activities_category",
                      "category": "account",
                    });
                  }),
                  filterOption("Products", selectedCategory == "product", () {
                    context.read<WidgetManipulatorCubit>().emitRandomElement({
                      "id": "select_activities_category",
                      "category": "product",
                    });
                  }),
                  filterOption("Stocks", selectedCategory == "stock", () {
                    context.read<WidgetManipulatorCubit>().emitRandomElement({
                      "id": "select_activities_category",
                      "category": "stock",
                    });
                  }),
                  filterOption("Sales", selectedCategory == "sale", () {
                    context.read<WidgetManipulatorCubit>().emitRandomElement({
                      "id": "select_activities_category",
                      "category": "sale",
                    });
                  }),
                ],
              ),
            ),
            BlocConsumer<ActionHistoryCubit, ActionHistoryState>(
              listener: (context, state) {
                if (state is ActionHistoryManagerLoaded) {
                  setState(() {
                    myHistory = state.historyList;
                    byModule = myHistory
                        .where((x) => x.module == module)
                        .toList();
                  });
                }
              },
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 15),
                    Text(
                      "Creation",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    itemMoreInformationsView(
                      myHistory: byModule
                          .where((x) => x.action == "create")
                          .toList(),
                      currentHist: currentHist,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Update",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 15),
                    itemMoreInformationsView(
                      myHistory: byModule
                          .where((x) => x.action == "update")
                          .toList(),
                      currentHist: currentHist,
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Other",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    itemMoreInformationsView(
                      myHistory: byModule
                          .where(
                            (x) => x.action != "update" && x.action != "create",
                          )
                          .toList(),
                      currentHist: currentHist,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  filterOption(String label, bool activated, Function onChangeCategory) {
    return GestureDetector(
      onTap: () {
        onChangeCategory();
      },
      child: Container(
        width: 130,
        height: 40,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: activated
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(05),
          border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
