import {UserPublic} from "./user-public";


export class UserFull extends UserPublic{

    constructor(
        uid: string,
        firstName: string,
        lastName: string,
        agoraUid: number,
        public readonly fcmToken: string,
    ) {
        super(uid, firstName, lastName, agoraUid);
    }
}
