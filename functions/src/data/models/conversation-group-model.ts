import {firestore} from "firebase-admin";
import Timestamp = firestore.Timestamp;
import {Conversation} from "../../domain/entities/conversation";
import {ConversationGroup} from "../../domain/entities/conversation-group";


export class ConversationGroupModel extends ConversationGroup {
    static readonly kTitle = "title";
    static readonly kCreatedBy = "createdBy";
    static readonly kAdminUids = "adminUids";
    static readonly kJoinedAt = "joinedAt";

    constructor(
        title: string,
        createdBy: string,
        adminUids: string[],
        joinedAt: {[p: string]: Date},
    ){
        super(title, createdBy, adminUids, joinedAt);
    }

    static fromData(data:any) : ConversationGroupModel | undefined {
        if (data == null) {
            return undefined;
        }

        return new ConversationGroupModel(
            data[ConversationGroupModel.kTitle],
            data[ConversationGroupModel.kCreatedBy],
            data[ConversationGroupModel.kAdminUids],
            Object.fromEntries(Object.entries(data[ConversationGroupModel.kJoinedAt]).map(([key, value]) => [key, (value as Timestamp).toDate()])),
        );
    }

}
