import {MutexService} from "./mutex-service";
import {usersService} from "./users-service";
import {firestore} from "firebase-admin";


class GetAgoraUidMutexService extends MutexService<{agoraUid: number}, {uid: string}> {

    constructor() {
        super("get-agora-uid-mutex", "administrative");
    }

    protected createDocumentForTheFirstTime(): FirebaseFirestore.WithFieldValue<FirebaseFirestore.DocumentData> {
        return { "nextAgoraUid": 1 };
    }

    protected getMutexId(input: { uid: string }): string {
        return input.uid;
    }

    protected async synchronized(input: {uid: string}, data: firestore.DocumentData, ref:firestore.DocumentReference): Promise<{ agoraUid: number }> {
        const agoraUid:number = data["nextAgoraUid"];
        await ref.update({ "nextAgoraUid": firestore.FieldValue.increment(1) });
        await usersService.updateUser(input.uid, { "agoraUid": agoraUid }, 'public');
        return { agoraUid: agoraUid };
    }


}

export const getAgoraUidMutexService = new GetAgoraUidMutexService();
