



export class Message {
    constructor(
        public readonly messageId: string,
        public readonly conversationId: string,
        public readonly text: string,
        public readonly senderUid: string,
        public readonly participants: string[],
        public readonly sentAt: Date,
        public readonly pendingRead: string[],
        public readonly pendingReceivement: string[],
        public readonly receivedAt: Map<String, Date>,
        public readonly readAt : Map<String, Date>,
    ) {}

    get isGroup(): boolean {
        return this.conversationId.startsWith('group_');
    }
}
