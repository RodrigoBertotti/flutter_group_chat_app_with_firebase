import 'package:flutter/material.dart';
import 'package:flutter_group_chat_app_with_firebase/core/utils/validators.dart';
import 'package:flutter_group_chat_app_with_firebase/features/groups/presentation/screens/manage_group_participants_screen.dart';
import '../../../../core/presentation/widgets/button_widget.dart';
import '../../../../core/presentation/widgets/my_appbar_widget.dart';
import '../../../../core/presentation/widgets/my_custom_text_form_field.dart';
import '../../../../core/presentation/widgets/my_scaffold.dart';
import '../../../../core/presentation/widgets/waves_background/waves_background.dart';
import '../../../../screen_routes.dart';
import '../../../chat/presentation/controllers/users_to_talk_to_controller.dart';
import '../../../login_and_registration/presentation/screens/widgets/animated_icon.dart';
import '../../../login_and_registration/presentation/widgets/separator.dart';
import '../controllers/create_group_or_edit_title_controller.dart';


class CreateGroupOrEditTitleArgs {
  final String? editExistingConversationId;
  CreateGroupOrEditTitleArgs({this.editExistingConversationId});
}

class CreateGroupOrEditTitleScreen extends StatefulWidget {
  static const String route = '/create-group-or-edit-title-screen';

  const CreateGroupOrEditTitleScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupOrEditTitleScreen> createState() => _CreateGroupOrEditTitleScreenState();
}

class _CreateGroupOrEditTitleScreenState extends State<CreateGroupOrEditTitleScreen> {
  final formKey = GlobalKey<FormState>();
  late CreateGroupOrEditTitleController controller;
  final groupsNameController = TextEditingController();

  final usersToTalkToController = UsersToTalkToController();
  CreateGroupOrEditTitleArgs? args;

  @override
  void initState() {
    super.initState();
    controller = CreateGroupOrEditTitleController(formKey: formKey, groupsNameController: groupsNameController);
    groupsNameController.addListener(() { setState(() {}); });
  }

  @override
  void dispose() {
    controller.dispose();
    formKey.currentState?.dispose();
    groupsNameController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (controller.initialized) {
      print("args already initialized");
      return;
    }
    args = ModalRoute.of(context)!.settings.arguments as CreateGroupOrEditTitleArgs?;
    controller.initialize(editExistingConversationId: args?.editExistingConversationId,);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final isGroupCreation = args?.editExistingConversationId == null;

    return MyScaffold(
        appBar: MyAppBarWidget(
          context: context,
          withBackground: true,
          child: ValueListenableBuilder(
            valueListenable: controller.notifyIsLoading,
            builder: (context, snapshot, _) {
              return Text(controller.title, style: const TextStyle(color: Colors.white,  overflow: TextOverflow.ellipsis,fontSize: 17, fontWeight: FontWeight.w600));
            },
          ),
        ),
        background: const WavesBackground(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .1,),

              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.indigo[700],
                    border: Border.all(color: Colors.indigo[900]!, width: 4)
                ),
                padding: const EdgeInsets.all(30),
                child: const Icon(Icons.group, size: 72, color: Colors.white),
              ),

              const SizedBox(height: 45,),

              Form(
                key: formKey,
                child: MyCustomTextFormField(
                  hintText: 'Group\'s title',
                  controller: controller.groupsNameController,
                  validator: validateRequired,
                  notifyError: controller.notifyGroupsNameError,
                  prefixIcon: MyAnimatedIcon(
                    icon: Icons.edit_note_sharp,
                    notifySuccess: controller.notifySuccess,
                    notifyError: controller.notifyGroupsNameError,
                  ),
                ),
              ),

              separator,

              if (!isGroupCreation)
                ValueListenableBuilder(
                  valueListenable: controller.notifyIsLoading,
                  builder: (__, isLoading, _) {
                    return ValueListenableBuilder(
                        valueListenable: controller.notifySuccess,
                        builder: (__, success, _) {
                          if (!isGroupCreation && (controller.conversation == null || controller.conversation!.group!.title == controller.groupsNameController.text || controller.groupsNameController.text.isEmpty)) {
                            return Container();
                          }
                          return Column(
                            children: [
                              ButtonWidget(
                                text: success ? "SUCCESS" : isGroupCreation ? "CREATE GROUP" : "SAVE NEW GROUP'S TITLE",
                                isLoading: isLoading && !success,
                                icon: success ? Icons.check : null,
                                backgroundColor: Colors.green,
                                onPressed: controller.onPressedEditGroupsTitle,
                              ),
                              const SizedBox(height: 14,),
                            ],
                          );
                        }
                    );
                  },
                ),

              if (isGroupCreation)
                ValueListenableBuilder(
                  valueListenable: controller.notifyIsLoading,
                  builder: (__, isLoading, _) {
                    return ValueListenableBuilder(
                        valueListenable: controller.notifySuccess,
                        builder: (__, success, _) {
                          return Column(
                            children: [
                              ButtonWidget(
                                text: success ? "SUCCESS" : "CREATE GROUP",
                                isLoading: isLoading && !success,
                                backgroundColor: Colors.blue[300],
                                icon: success ? Icons.check : null,
                                onPressed: controller.onPressedCreateNewGroup,
                              ),
                              const SizedBox(height: 14,),
                            ],
                          );
                        }
                    );
                  },
                ),

              if (!isGroupCreation)
                ButtonWidget(
                  text: "MANAGE USERS",
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                        ScreenRoutes.manageGroupParticipants,
                        arguments: ManageGroupParticipantsScreenArgs(conversationId: controller.conversation!.conversationId)
                    ).then(Navigator.of(context).pop);
                  },
                ),

              ValueListenableBuilder(
                  valueListenable: controller.notifySuccess,
                  builder: (context, success, widget) => !success
                      ? Container()
                      : Column(
                    children: [
                      const SizedBox(height: 20,),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(15)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            child: Text(isGroupCreation ? 'Group has been successfully created' : 'Group has been successfully edited', textAlign: TextAlign.center, style: TextStyle(color: Colors.green[900], fontSize: 15, letterSpacing: .8, fontWeight: FontWeight.w600)),
                          )
                      )
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }
}

