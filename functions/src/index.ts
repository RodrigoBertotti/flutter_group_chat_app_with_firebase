import {onDocumentDeleted, onDocumentCreated, onDocumentUpdated} from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {onCall, onRequest} from 'firebase-functions/v2/https';
import {messagesService} from "./domain/services/messages-service";
import {usersService} from "./domain/services/users-service";
import {notificationsService} from "./domain/services/notifications-service";
import {MessageModel} from "./data/models/message-model";
import {Message} from "./domain/entities/message";
import {ConversationModel} from "./data/models/conversation-model";
import {getCallCredentials} from "./middlewares/calls/calls";
import * as agora from "agora-token";
import {environment} from "./environment";
import {db} from "./data/datasource/db";

admin.initializeApp();

exports.onUserDeleted = onDocumentDeleted("users/{userId}", async (event) => {
    await admin.auth().deleteUser(event.data!.id);
    await db().collection("users").doc(event.data!.id).collection("fullUser").doc("data").delete();
});

exports.onMessageCreated = onDocumentCreated("conversations/{conversationId}/messages/{messageId}", async (event) => {
    console.log(`message ${event.params.messageId} has been created in conversation ${event.params.conversationId}`);
    const message:Message = MessageModel.fromData(event.data!.data());

    const senderUser = (await usersService.getPublicUser(message.senderUid));
    const title = message.isGroup
        ? (await messagesService.getConversation(message.conversationId))!.group!.title
        : senderUser.fullName;

    for (const uid of message.participants.filter((participant) => participant != message.senderUid)) {
        await notificationsService.sendPushNotificationToDevice({
            uid: uid,
            title: `💬 ${title.toUpperCase()}`,
            body: message.isGroup ? `${senderUser.fullName}: ${message.text}` : message.text,
            data: message.isGroup ? {
                conversationId: message.conversationId,
            } : {
                conversationId: message.conversationId,
                uidForDirectConversation: message.senderUid,
            }
        });
    }
});

exports.onConversationDeleted = onDocumentDeleted("conversations/{conversationId}", async (event) => {
    await messagesService.deleteAllMessages(event.params.conversationId);
});

exports.onConversationUpdated = onDocumentUpdated("conversations/{conversationId}", async (event) => {
    console.log(`conversation ${event.params.conversationId} has been updated`);
    const conversationBeforeUpdate = ConversationModel.fromData(event.data.before.data());
    const conversationAfterUpdate = ConversationModel.fromData(event.data.after.data());
    const removedParticipants = conversationAfterUpdate.removedParticipants(conversationBeforeUpdate);
    if (removedParticipants.length && conversationBeforeUpdate.participants.length - removedParticipants.length <= (conversationBeforeUpdate.group ? 0 : 1)) {
        console.log(`conversation ${event.params.conversationId} will be deleted`);
        await event.data.after.ref.delete();
    } else if (removedParticipants.length) {
        await messagesService.removeParticipantsInConversationMessages(conversationAfterUpdate.conversationId, removedParticipants);
        console.log(`${removedParticipants.length} participants were removed from conversation ${event.params.conversationId}`);
    }
});

exports.getCallCredentials = functions.https.onCall(getCallCredentials);
