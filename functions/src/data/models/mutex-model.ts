import {Mutex} from "../../domain/entities/mutex";


export class MutexModel extends Mutex {
    static kLocksQueue = "locksQueue";
    locksQueue: string[];

    constructor(locksQueue: string[]) {
        super(locksQueue);
    }

    toData() {
        return {
            [MutexModel.kLocksQueue]: this.locksQueue,
        } as {[p:string]: any}
    }

    static fromData(data:any) : MutexModel {
        return new MutexModel(data[MutexModel.kLocksQueue]);
    }
}
