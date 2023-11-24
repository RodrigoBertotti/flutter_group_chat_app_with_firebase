import {Message} from "../../domain/entities/message";
import * as admin from "firebase-admin"
import {fromMapOfTimestamp} from "../../utils";

export class MessageModel extends Message {
    static readonly kConversationId = "conversationId";
    static readonly kMessageId = "messageId";
    static readonly kText = "text";
    static readonly kSenderUid = "senderUid";
    static readonly kParticipants = "participants";
    static readonly kReceivedAt = "receivedAt";
    static readonly kReadAt = "readAt";
    static readonly kSentAt = "sentAt";
    static readonly kPendingRead = "pendingRead";
    static readonly kPendingReceivement = "pendingReceivement";

    constructor(
        messageId: string,
        conversationId: string,
        text: string,
        senderUid: string,
        participants: string[],
        sentAt: Date,
        pendingRead: string[],
        pendingReceivement: string[],
        receivedAt: Map<String, Date>,
        readAt: Map<String, Date>,
    ) {
        super(messageId, conversationId, text, senderUid, participants, sentAt, pendingRead, pendingReceivement, receivedAt, readAt,);
    }

    static fromData(data: any) : MessageModel {
        return new MessageModel(
            data[MessageModel.kMessageId],
            data[MessageModel.kConversationId],
            data[MessageModel.kText],
            data[MessageModel.kSenderUid],
            data[MessageModel.kParticipants],
            (data[MessageModel.kSentAt] as admin.firestore.Timestamp).toDate(),
            data[MessageModel.kPendingRead],
            data[MessageModel.kPendingReceivement],
            fromMapOfTimestamp(data[MessageModel.kReceivedAt]),
            fromMapOfTimestamp(data[MessageModel.kReadAt]),
        );
    }

}
