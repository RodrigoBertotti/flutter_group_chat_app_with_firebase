import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_group_chat_app_with_firebase/features/groups/presentation/screens/add_participants_screen.dart';
import 'package:flutter_group_chat_app_with_firebase/injection_container.dart';
import 'package:flutter_group_chat_app_with_firebase/main.dart';
import 'package:flutter_group_chat_app_with_firebase/screen_routes.dart';
import '../../../chat/domain/entities/conversation.dart';
import '../../../chat/domain/services/messages_service.dart';
import '../../domain/services/groups_service.dart';

class CreateGroupOrEditTitleController {
  String? editExistingConversationId;
  bool _initialized = false;

  final GlobalKey<FormState> formKey;
  final ValueNotifier<bool> notifyIsLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> notifySuccess = ValueNotifier<bool>(false);
  ValueNotifier<String?> notifyGroupsNameError = ValueNotifier<String?>(null);
  Conversation? conversation;
  final TextEditingController groupsNameController;

  CreateGroupOrEditTitleController({required this.formKey, required this.groupsNameController});

  bool get initialized => _initialized;

  String get title {
    if (notifyIsLoading.value) {
      return "loading...";
    }
    if (conversation != null) {
      return conversation!.group!.title;
    }
    return 'Creating a New Group';
  }

  void Function()? get onPressedEditGroupsTitle {
    return notifySuccess.value || notifyIsLoading.value ? null : () async {
      notifyIsLoading.value = notifySuccess.value = false;

      FocusManager.instance.primaryFocus?.unfocus();

      if(formKey.currentState!.validate()){
        notifyGroupsNameError.value = null;
        formKey.currentState!.save();
        notifyIsLoading.value = true;

        await getIt.get<GroupsService>().editGroupsTitle(groupTitle: groupsNameController.text, conversationId: conversation!.conversationId,);

        conversation!.group!.title = groupsNameController.text;
        notifyIsLoading.value = false;
        notifySuccess.value = true;
        Future.delayed(const Duration(milliseconds: 1500), () {
          notifySuccess.value = false;
          if (conversation == null) {
            Navigator.of(navigatorKey.currentContext!).pop();
          }
        });
      }
    };
  }

  void Function()? get onPressedCreateNewGroup {
    return notifySuccess.value || notifyIsLoading.value ? null : () async {
      notifyIsLoading.value = notifySuccess.value = false;

      FocusManager.instance.primaryFocus?.unfocus();

      if(formKey.currentState!.validate()){
        notifyGroupsNameError.value = null;
        formKey.currentState!.save();
        notifyIsLoading.value = true;

        conversation = await getIt.get<GroupsService>().createGroup(groupTitle: groupsNameController.text,);
        groupsNameController.text = conversation!.group!.title;

        notifyIsLoading.value = false;
        notifySuccess.value = true;
        Future.delayed(const Duration(milliseconds: 1500), () {
          notifySuccess.value = false;
          Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil(ScreenRoutes.addGroupParticipants, (route) => route.isFirst, arguments: AddGroupParticipantsScreenArgs(conversationId: conversation!.conversationId));
        });
      }
    };
  }

  void initialize({
    String? editExistingConversationId,
  }) {
    assert(!_initialized);
    _initialized = true;
    this.editExistingConversationId = editExistingConversationId;
    notifyIsLoading.value = editExistingConversationId != null;
    if (editExistingConversationId != null) {
      getIt.get<MessagesService>().getConversationById(
          conversationId: editExistingConversationId)
          .then((conversation) {
            this.conversation = conversation;
            groupsNameController.text = conversation!.group!.title;
            notifyIsLoading.value = false;
          });
    }

  }

  void dispose() {
    notifyIsLoading.dispose();
    notifySuccess.dispose();
    notifyGroupsNameError.dispose();
  }
}