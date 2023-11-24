import {UserPublic} from "../../domain/entities/user-public";
import {firestore} from "firebase-admin";
import DocumentData = firestore.DocumentData;


export class UserPublicModel extends UserPublic {
    static readonly kUid = "uid";
    static readonly kFirstName = "firstName";
    static readonly kLastName = "lastName";
    static readonly kAgoraUid = "agoraUid";

    constructor(
        uid: string,
        firstName: string,
        lastName: string,
        agoraUid: number,
    ) {
        super(uid, firstName, lastName, agoraUid);
    }

    static fromData(data:DocumentData | undefined) : UserPublicModel | null {
        if (!data) {
            return null;
        }
        return new UserPublicModel(
            data[UserPublicModel.kUid],
            data[UserPublicModel.kFirstName],
            data[UserPublicModel.kLastName],
            data[UserPublicModel.kAgoraUid],
        )
    }
}
