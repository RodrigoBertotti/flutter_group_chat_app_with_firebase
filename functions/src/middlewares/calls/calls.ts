import * as functions from "firebase-functions";
import * as agora from "agora-token";
import {usersService} from "../../domain/services/users-service";
import {environment} from "../../environment";
import {notificationsService} from "../../domain/services/notifications-service";
import {messagesService} from "../../domain/services/messages-service";
import {UserFull} from "../../domain/entities/user-full";
import {Conversation} from "../../domain/entities/conversation";

function getNotificationTitle(user:UserFull, conversation:Conversation) {
    if (conversation.isGroup) {
        return `Meeting is underway in ${conversation.group.title}`;
    }
    return `${user.fullName} is calling you`;
}
function getNotificationBody(user:UserFull, conversation:Conversation) {
    if (conversation.isGroup) {
        return `${user.fullName} joined the meeting, click here to join too`;
    }
    return `Click here to join`;
}

export const getCallCredentials = async (data: any, context: functions.https.CallableContext) : Promise<any> => {
    if (!context.auth?.uid) {
        throw new Error("getCallToken: user must be authenticated");
    }
    const conversationId = data["conversationId"];
    if (!conversationId?.length) throw new Error("getCallToken: conversationId must not be null");

    const conversation = await messagesService.getConversation(conversationId);
    const user = await usersService.getFullUser(context.auth.uid);
    for (let uid of conversation.participants) {
        if (uid != context.auth.uid) {
            await notificationsService.sendPushNotificationToDevice({
                uid: uid,
                data: {"conversationId": conversationId, "joinCall": 'true'},
                title: getNotificationTitle(user, conversation),
                body: getNotificationBody(user, conversation),
            })
        }
    }

    const agoraUid = await usersService.getAgoraUid(context.auth.uid, user);
    const rtcToken = agora.RtcTokenBuilder.buildTokenWithUid(
        environment.agora.appID,
        environment.agora.appCertificate,
        conversationId,
        agoraUid,
        agora.RtcRole.PUBLISHER,
        86400,
        86400,
    );
    return { rtcToken: rtcToken, agoraUid: agoraUid, };
}
