import {ConversationGroup} from "./conversation-group";


export class Conversation {

    constructor(
       public readonly conversationId: string,
       public readonly participants: string[],
       public readonly group?: ConversationGroup,
    ) {}

    get isGroup () : boolean {
        return this.group != null;
    }

    removedParticipants(conversationBeforeUpdate:Conversation) : Array<string> {
        return conversationBeforeUpdate.participants
            .filter((uid) => conversationBeforeUpdate.participants.includes(uid))
            .filter((uid) => !this.participants.includes(uid));
    }
}
