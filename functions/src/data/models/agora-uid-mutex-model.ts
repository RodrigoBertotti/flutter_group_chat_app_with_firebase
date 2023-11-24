import {MutexModel} from "./mutex-model";


export class AgoraUidMutexModel extends MutexModel {
    static kNextAgoraUid = "nextAgoraUid";
    constructor(
        locksQueue: string[],
        public readonly nextAgoraUid: number,
    ) {
        super(locksQueue);
    }

    toData() {
        const res = super.toData();
        res[AgoraUidMutexModel.kNextAgoraUid] = this.nextAgoraUid;
        return res;
    }

    static fromData(data:any) : AgoraUidMutexModel {
        return new AgoraUidMutexModel(
            data[MutexModel.kLocksQueue],
            data[AgoraUidMutexModel.kNextAgoraUid],
        );
    }
}
