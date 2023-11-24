import {Conversation} from "../entities/conversation";
import {messagesDatasource} from "../../data/datasource/messages-datasource";


class MessagesService {

    getConversation (conversationId:string) : Promise<Conversation | undefined> {
        return messagesDatasource.getConversation(conversationId);
    }

    removeParticipantsInConversationMessages (conversationId:string, participantsUids: string[]) : Promise<void> {
        return messagesDatasource.removeParticipantsInMessages(conversationId, participantsUids);
    }

    deleteAllMessages(conversationId: string) : Promise<void> {
        return messagesDatasource.deleteAllMessages(conversationId);
    }
}

export const messagesService = new MessagesService();
