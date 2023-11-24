import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/domain/entities/user_public.dart';
import 'package:flutter_group_chat_app_with_firebase/core/presentation/snackbar.dart';
import 'package:flutter_group_chat_app_with_firebase/features/groups/presentation/screens/add_participants_screen.dart';
import 'package:flutter_group_chat_app_with_firebase/screen_routes.dart';
import '../../../../core/presentation/confirmation_modal.dart';
import '../../../../core/presentation/widgets/button_widget.dart';
import '../../../../core/presentation/widgets/center_content_widget.dart';
import '../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../core/presentation/widgets/my_scaffold.dart';
import '../../../../core/presentation/widgets/person_icon.dart';
import '../controllers/manage_group_participants_controller.dart';

class ManageGroupParticipantsScreenArgs {
  final String conversationId;
  const ManageGroupParticipantsScreenArgs({required this.conversationId});
}

class ManageGroupParticipantsScreen extends StatefulWidget {
  static const route = "conversation/manage-participants";

  const ManageGroupParticipantsScreen({super.key});

  @override
  State<ManageGroupParticipantsScreen> createState() => _ManageGroupParticipantsScreenState();
}

class _ManageGroupParticipantsScreenState extends State<ManageGroupParticipantsScreen> {
  ManageGroupParticipantsScreenArgs? args;
  bool initialized = false;
  final searchController = TextEditingController(text: '');
  final manageGroupParticipantsController = ManageGroupParticipantsController();
  
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
    args = ModalRoute.of(context)!.settings.arguments as ManageGroupParticipantsScreenArgs?;
    manageGroupParticipantsController.init(conversationId: args!.conversationId);
    initialized = true;
  }


  @override
  void dispose() {
    manageGroupParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize1 = 24;
    const double iconSize2 = 20;
    const double paddingSize1 = 5;
    const double paddingSize2 = 7;
    assert(iconSize1 + 2 * paddingSize1 == iconSize2 + 2 * paddingSize2);

    return MyScaffold(
      background: defaultBackground,
      appBar: MyAppBarWidget(
        context: context,
        child: const Text('Participants', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            clipBehavior: Clip.none,
            child: StreamBuilder(
              stream: manageGroupParticipantsController.readGroupStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white,),);
                }
                final borderRadius = BorderRadius.circular(15.0);
                return Column(
                  children: [
                    ...(manageGroupParticipantsController.participants).map((user) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: borderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.55),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(5, 5), // changes position of shadow
                                ),
                              ]
                          ),
                          child: ClipRRect(
                            borderRadius: borderRadius,
                            child: Dismissible(
                                key: Key('_list_${user.uid}'),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (_) => removeUserHandler(user),
                                background: Container(
                                  clipBehavior: Clip.none,
                                  decoration: BoxDecoration(
                                      color: Colors.red
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.remove_circle_outline_rounded, color: Colors.white),
                                            Text("Remove user", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                child: InkWell(
                                  onTap: () => openModalAboutParticipant(user),
                                  child: Ink(
                                    child: Container(
                                      clipBehavior: Clip.none,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              PersonIcon(isGroup: false),
                                              SizedBox(width: 10,),
                                              Text(user.fullName, style: TextStyle(fontSize: 16, color: Colors.blue[900], fontWeight: FontWeight.w700)),
                                            ],
                                          ),
                                          if (manageGroupParticipantsController.isAdmin(user.uid))
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xffFFD700),
                                                  borderRadius: BorderRadius.circular(100)
                                              ),
                                              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                                              child: Text("ADMIN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.indigo[900])),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 50,),
                  ],
                );
              },
            ),
          ),
          Align(
            alignment: Alignment(1, 1),
            child: ButtonWidget(
              icon: Icons.add_circle,
              backgroundColor: Colors.blue[900],
              text: "ADD PARTICIPANTS",
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(ScreenRoutes.addGroupParticipants, arguments: AddGroupParticipantsScreenArgs(conversationId: manageGroupParticipantsController.conversationId), (route) => route.settings.name != ScreenRoutes.manageGroupParticipants && route.settings.name != ScreenRoutes.createGroupOrEditTitle,);
              },
            ),
          )
        ],
      ),
    );
  }
  
  Future<void> openModalAboutParticipant (UserPublic user) async {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
        context: context,
        builder: (context) {
          Widget button ({required IconData icon, required String text, required void Function() onPressed, Color? backgroundColor}) {
            return SizedBox(
              width: 250,
              child: ButtonWidget(icon: icon, text: text, isSmall: true, width: double.infinity, onPressed: onPressed, backgroundColor: backgroundColor),
            );
          }
          return IntrinsicHeight(
            child: CenterContentWidget(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PersonIcon(isGroup: false, iconSize: 18, iconInternalPadding: EdgeInsets.all(3)),
                        SizedBox(width: 5,),
                        Text(user.fullName, style: TextStyle(color: Colors.indigo[900], fontSize: 18, fontWeight: FontWeight.w800),),
                      ],
                    ),
                    const SizedBox(height: 18,),
                    if (!manageGroupParticipantsController.isAdmin(user.uid))
                      button(
                          icon: Icons.rocket,
                          text: 'ADD ADMIN PRIVILEGE',
                          onPressed: () {
                            Navigator.of(context).pop();
                            manageGroupParticipantsController.addAdminPrivilege(user.uid)
                                .then((_) {
                              showSnackBar(message: '${user.fullName} is now an Admin');
                            });
                          }
                      ),
                    if (manageGroupParticipantsController.isAdmin(user.uid))
                      button(
                          icon: Icons.rotate_90_degrees_ccw_sharp,
                          text: 'REMOVE ADMIN PRIVILEGE',
                          backgroundColor: Colors.red[300],
                          onPressed: () {
                            Navigator.of(context).pop();
                            manageGroupParticipantsController.removeAdminPrivilege(user.uid)
                                .then((_) {
                              showSnackBar(message: '${user.fullName} is not an Admin anymore');
                            });
                          }
                      ),
                    const SizedBox(height: 18,),
                    button(icon: Icons.remove_circle_outline_rounded, backgroundColor: Colors.red[300], text: 'REMOVER USER', onPressed: () {
                      Navigator.of(context).pop();
                      removeUserHandler(user);
                    }),
                    const SizedBox(height: 18,),
                    button(icon: Icons.keyboard_arrow_left_rounded, backgroundColor: Colors.blue[800]!.withOpacity(.5), text: 'GO BACK', onPressed: () => Navigator.of(context).pop()),
                  ],
                ),
              ),
            ),
          );
        }
     );
  }

  Future<bool?> removeUserHandler(UserPublic user) {
    return showConfirmationModal(
      context: context,
      title: "Are you sure?",
      message: "${user.fullName} will be removed from the group",
      confirmButtonText: "REMOVE",
    ).then((confirmed) {
      if (confirmed) {
        manageGroupParticipantsController.removeParticipant(uid: user.uid)
          .then((_) {
            showSnackBar(message: '${user.fullName} has been removed from ${manageGroupParticipantsController.conversation!.group!.title}');
          });
      }
      return confirmed;
    });
  }
}

class _Subtitle extends StatelessWidget {
  final String text;
  
  const _Subtitle({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Text(text, style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),),
      padding: EdgeInsets.only(bottom: 3),
    );
  }
}

