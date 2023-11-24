import {UserFull} from "../../domain/entities/user-full";
import {UserPublicModel} from "./user-public-model";


export class UserFullModel extends UserFull {
    static readonly kFcmToken = "fcmToken";
    constructor(
        uid: string,
        firstName: string,
        lastName: string,
        agoraUid: number,
        fcmToken: string,
    ) {
        super(uid, firstName, lastName, agoraUid, fcmToken);
    }

    static fromData(data:any) : UserFullModel | undefined {
        if (!data) {
            return undefined;
        }
        return new UserFullModel(
            data[UserPublicModel.kUid],
            data[UserPublicModel.kFirstName],
            data[UserPublicModel.kLastName],
            data[UserPublicModel.kAgoraUid],
            data[UserFullModel.kFcmToken],
        )
    }

}
