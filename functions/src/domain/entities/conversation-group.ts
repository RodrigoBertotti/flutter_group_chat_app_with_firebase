


export class ConversationGroup {

    constructor(
       public readonly title: string,
       public readonly createdBy: string,
       public readonly adminUids: string[],
       public readonly joinedAt: {[p: string]: Date},
    ) {}

}
