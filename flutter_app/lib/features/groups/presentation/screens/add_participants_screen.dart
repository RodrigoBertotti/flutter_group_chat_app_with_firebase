import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/widgets/my_scaffold.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import '../../../../core/presentation/widgets/button_widget.dart';
import '../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../core/presentation/widgets/my_multiline_text_field.dart';
import '../../../../core/presentation/widgets/person_icon.dart';
import '../../../../core/presentation/snackbar.dart';
import '../controllers/add_participants_controller.dart';

class AddGroupParticipantsScreenArgs {
  final String conversationId;
  const AddGroupParticipantsScreenArgs({required this.conversationId});
}

class AddGroupParticipantsScreen extends StatefulWidget {
  static const route = "conversation/add-participants";

  const AddGroupParticipantsScreen({super.key});

  @override
  State<AddGroupParticipantsScreen> createState() => _AddGroupParticipantsScreenState();
}

class _AddGroupParticipantsScreenState extends State<AddGroupParticipantsScreen> {
  AddGroupParticipantsScreenArgs? args;
  bool initialized = false;
  late final AddParticipantsController controller;
  final searchController = TextEditingController(text: '');
  
  @override
  void initState() {
    super.initState();
    searchController.addListener(() {setState(() {});});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (initialized) {
      print("already initialized, ignoring didChangeDependencies");
      return;
    }
    assert(ModalRoute.of(context)!.settings.arguments != null, "Please, inform the arguments. More info on https://docs.flutter.dev/cookbook/navigation/navigate-with-arguments#4-navigate-to-the-widget");
    args = ModalRoute.of(context)!.settings.arguments as AddGroupParticipantsScreenArgs?;
    initialized = true;
    controller = AddParticipantsController(conversationId: args!.conversationId);
    controller.initialize();
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize1 = 24;
    const double iconSize2 = 20;
    const double paddingSize1 = 5;
    const double paddingSize2 = 7;
    const double spaceAfterIcon = 12;
    const double borderWidth = 1;

    assert(iconSize1 + 2 * paddingSize1 == iconSize2 + 2 * paddingSize2);

    return MyScaffold(
      appBar: MyAppBarWidget(
        context: context,
        child: const Text('Adding Participants', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      background: Container(decoration: BoxDecoration(color: Colors.blue[700]),),
      padding: const EdgeInsets.only(top: 1, bottom: kMargin, right: kMargin, left: kMargin),
      body: ValueListenableBuilder(
          valueListenable: controller.notifySelectedUsers,
          builder: (context, users, _) {
            final selectCount = users.entries.where((entry) => entry.value.$2).length;
            final filteredUsers = users.entries.where(checkIfMatchesFilter);
            return SizedBox(
              height: double.infinity,
              child: Stack(
                children: [
                  SingleChildScrollView(
                    clipBehavior: Clip.none,
                    child: Column(
                      children: [
                        if (controller.outsideGroupUsers?.isNotEmpty == true)
                          ...[
                            const SizedBox(height: 8,),
                            MyMultilineTextField(
                              hintText: 'Search for users',
                              controller: searchController,
                              fillColor: Colors.blue[800], // <--
                              maxLines: 1,
                              suffixIcon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return ScaleTransition(scale: animation, child: child);
                                },
                                child: searchController.text.isEmpty
                                    ? Icon(Icons.search_rounded, color: Colors.blue[900]!, size: 27)
                                    : InkWell(
                                  onTap: _clearText,
                                  child: Ink(
                                    child: const Icon(Icons.clear_rounded, color: Colors.white, size: 27,),
                                  ),
                                ),
                              ),
                            ),
                          ],

                        const SizedBox(height: 8,),

                        ...filteredUsers.mapIndexed((i, e) {
                          return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: InkWell(
                                onTap: () {
                                  controller.selectUserChanged(e.value.$1.uid, !e.value.$2);
                                },
                                child: Ink(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (e.value.$2)
                                                      const PersonIcon(isGroup: false, borderWidth: borderWidth, iconSize: iconSize1, iconInternalPadding: EdgeInsets.all(paddingSize1)),
                                                    if (!e.value.$2)
                                                      const PersonIcon(isGroup: false, borderWidth: borderWidth, iconSize: iconSize2, iconInternalPadding: EdgeInsets.all(paddingSize2)),
                                                    const SizedBox(width: spaceAfterIcon,),
                                                  ],
                                                ),
                                                Text(e.value.$1.fullName, style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: e.value.$2 ? FontWeight.w700 : FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: MSHCheckbox(
                                              size: 22,
                                              value: e.value.$2,
                                              colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
                                                  checkedColor: Colors.white,
                                                  uncheckedColor: Colors.blue[100]!
                                              ),
                                              style: MSHCheckboxStyle.stroke,
                                              onChanged: (_) {
                                                controller.selectUserChanged(e.value.$1.uid, !e.value.$2);
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 10,),
                                      if (i < filteredUsers.length - 1)
                                        Row(
                                          children: [
                                            const SizedBox(width: spaceAfterIcon + iconSize1 + 2*paddingSize1 + 2*borderWidth,),
                                            Expanded(child: Container(color: Colors.lightBlue[50], width: 100, height: .3,),)
                                          ],
                                        )
                                    ],
                                  ),
                                ),
                              )
                          );
                        }).toList()
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      children: [
                        if (selectCount > 0)
                          ...[
                            ButtonWidget(
                              icon: Icons.add_task_rounded,
                              text: "ADD $selectCount PARTICIPANTS",
                              backgroundColor: Colors.blue[900],
                              onPressed:  () {
                                controller.addParticipants()
                                    .then((_) {
                                  showSnackBar(
                                    message: selectCount == 1 ? "1 participant added to ${controller.conversation!.group!.title}" : "$selectCount participants added to ${controller.conversation!.group!.title}",
                                    icon: Icons.check,
                                  );
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            const SizedBox(height: 10,),
                          ],
                        ButtonWidget(
                          icon: Icons.cancel_outlined,
                          backgroundColor: Colors.grey[400]!.withOpacity(.9),
                          text: controller.outsideGroupUsers?.isEmpty == true ? "CLOSE" : "CANCEL",
                          onPressed:  () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  if (controller.outsideGroupUsers?.isEmpty == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * .3,),
                        Icon(Icons.supervised_user_circle, color: Colors.white.withOpacity(.5), size: 80),
                        const SizedBox(height: 10,),
                        Text("All participants are already in\n${controller.conversation!.group!.title}", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20), textAlign: TextAlign.center,)
                      ],
                    )
                ],
              ),
            );
          }
      ),
    );
  }

  void _clearText() {
    setState(() {
      searchController.text = '';
    });
  }

  bool checkIfMatchesFilter(MapEntry<String, (UserPublic, bool)> element) {
    String unformatted (String value) {
      return value.toString().toLowerCase().replaceAll(' ', '');
    }
    return unformatted(element.value.$1.fullName).contains(unformatted(searchController.text));
  }
}
