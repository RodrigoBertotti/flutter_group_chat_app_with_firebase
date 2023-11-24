import {firestore} from "firebase-admin";
import Timestamp = firestore.Timestamp;
import {Conversation} from "../../domain/entities/conversation";
import {ConversationGroup} from "../../domain/entities/conversation-group";
import {ConversationGroupModel} from "./conversation-group-model";


export class ConversationModel extends Conversation {
    static readonly kConversationId = "conversationId";
    static readonly kParticipants = "participants";
    static readonly kTyping = "typing";
    static readonly kGroup = "group";

    constructor(
        conversationId: string,
        participants: string[],
        group?: ConversationGroup,
    ){
        super(conversationId, participants, group);
    }

    static fromData(data:any) : ConversationModel | null {
        if (!data) {
            return null;
        }

        return new ConversationModel(
            data[ConversationModel.kConversationId],
            data[ConversationModel.kParticipants],
            ConversationGroupModel.fromData(data[ConversationModel.kGroup])
        );
    }

}
