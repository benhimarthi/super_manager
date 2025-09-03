import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/features/action_history/domain/entities/action.history.dart';
import 'package:super_manager/features/authentication/presentation/pages/user_management_screen/changes.display.widget.dart';
import 'package:super_manager/features/widge_manipulator/cubit/widget.manipulator.cubit.dart';

itemMoreInformationsView({
  required List<ActionHistory> myHistory,
  required String currentHist,
}) {
  return SingleChildScrollView(
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: List.generate(myHistory.length, (index) {
            return historyItem(myHistory[index], currentHist);
          }),
        ),
      ],
    ),
  );
}

Map<dynamic, Map<dynamic, dynamic>> findChangedFieldsWithValues(
  Map<dynamic, dynamic> data,
) {
  final oldVersion = data['old_version'] as Map<dynamic, dynamic>? ?? {};
  final newVersion = data['new_version'] as Map<dynamic, dynamic>? ?? {};
  final allKeys = <dynamic>{}
    ..addAll(oldVersion.keys)
    ..addAll(newVersion.keys);

  final changes = <dynamic, Map<dynamic, dynamic>>{};

  for (final key in allKeys) {
    final oldVal = oldVersion[key];
    final newVal = newVersion[key];

    bool isEqual = false;
    if ((oldVal == null || oldVal.toString().isEmpty) &&
        (newVal == null || newVal.toString().isEmpty)) {
      isEqual = true;
    } else {
      isEqual = oldVal == newVal;
    }

    if (!isEqual) {
      changes[key] = {'old': oldVal, 'new': newVal};
    }
  }
  return changes;
}

historyItem(ActionHistory? element, String currentHist) {
  return element != null
      ? Stack(
          children: [
            Builder(
              builder: (context) {
                final time = element.timestamp;
                String formatedDate = "${time.day}-${time.month}-${time.year}";
                String formatedTime =
                    "${time.hour}h : ${time.minute}min : ${time.second}sec";
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(formatedDate, style: TextStyle(color: Colors.white)),
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Icon(Icons.edit, size: 15),
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        context
                            .read<WidgetManipulatorCubit>()
                            .emitRandomElement({
                              "id": "show_history_detail",
                              "element_id": element.timestamp.toString(),
                            });
                      },
                      child: Container(
                        width: 220,
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(44, 255, 255, 255),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color.fromARGB(98, 255, 255, 255),
                            width: 1,
                          ),
                        ),
                        child: currentHist != element.timestamp.toString()
                            ? Text(
                                element.action,
                                style: TextStyle(color: Colors.white),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  cText("time", formatedTime, Colors.green),
                                  cText("Action", element.action, Colors.green),
                                  cText(
                                    "Description",
                                    element.description,
                                    Colors.green,
                                  ),
                                  cText("Module", element.module, Colors.green),
                                  cText(
                                    "Performed by",
                                    element.performedByName,
                                    Colors.green,
                                  ),
                                  cText(
                                    "Status after",
                                    element.statusAfter,
                                    Colors.green,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 2,
                                    color: const Color.fromARGB(
                                      29,
                                      255,
                                      255,
                                      255,
                                    ),
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 110,
                                    child: ChangesDisplayWidget(
                                      changes: findChangedFieldsWithValues(
                                        element.changes[element
                                                .changes
                                                .keys
                                                .first]
                                            as Map<dynamic, dynamic>,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        )
      : SizedBox();
}

cText(String header, String content, Color color) {
  return Text.rich(
    TextSpan(
      text: "$header : ",
      children: [
        TextSpan(
          text: content,
          style: TextStyle(color: Colors.white),
        ),
      ],
      style: TextStyle(color: color, fontWeight: FontWeight.bold),
    ),
  );
}
