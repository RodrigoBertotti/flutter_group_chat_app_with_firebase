import {Conversation} from "../../domain/entities/conversation";
import {db} from "./db";
import {ConversationModel} from "../models/conversation-model";
import {MessageModel} from "../models/message-model";
import * as admin from "firebase-admin"

class MessagesDatasource {

    async getConversation (conversationId: string): Promise<Conversation | null> {
        const data = (
            await db()
                .collection("conversations")
                .doc(conversationId)
                .get()
        ).data();

        return ConversationModel.fromData(data);
    }

    async removeParticipantsInMessages (conversationId:string, participantsUids: string[]): Promise<void>  {
        console.log("removeParticipantsInMessages: "+"  " + conversationId + "  " +participantsUids + " " + Array.isArray(participantsUids));
        const snapshot = await  db()
            .collection("conversations")
            .doc(conversationId)
            .collection("messages")
            .where(MessageModel.kParticipants, "array-contains-any", participantsUids)
            .get();

        for (const message of snapshot.docs) {
            console.log("snapshot.docs: "+"  " + snapshot.docs.length);

            if (message.data()[MessageModel.kParticipants].length) {
                await message.ref.update({
                    [MessageModel.kParticipants]: admin.firestore.FieldValue.arrayRemove(...participantsUids),
                    [MessageModel.kPendingRead]: admin.firestore.FieldValue.arrayRemove(...participantsUids),
                    [MessageModel.kPendingReceivement]: admin.firestore.FieldValue.arrayRemove(...participantsUids),
                });
            } else {
                await message.ref.delete();
            }
        }
    }

    async deleteAllMessages(conversationId: string): Promise<void> {
        const snapshot = await db()
            .collection("conversations")
            .doc(conversationId)
            .collection("messages")
            .get();
        for (const message of snapshot.docs) {
            message.ref.delete();
        }
    }
}

export const messagesDatasource = new MessagesDatasource();
