import {db} from "../../data/datasource/db";
import {firestore} from "firebase-admin";
import FieldValue = firestore.FieldValue;


export abstract class MutexService<RESULT, INPUT> {

    protected constructor(protected readonly documentId: string, protected readonly collection: string = "mutex", protected readonly timeoutInSeconds: number = 20) {};

    protected abstract synchronized(input: INPUT, data: firestore.DocumentData, ref: firestore.DocumentReference): Promise<RESULT>;

    protected createDocumentForTheFirstTime() : firestore.WithFieldValue<firestore.DocumentData> {
        return {};
    }
    protected getMutexId(input:INPUT) {
        return `mutex_${db().collection("_").doc().id}`;
    }

    async call(input:INPUT): Promise<RESULT> {
        let cancelSubscription: () => void;
        let pendingUpdate = true;
        let rejectPromise: (reason?: any) => void;
        const ref =  db().collection(this.collection).doc(this.documentId);

        const timeoutId = setTimeout(async () => {
            if (cancelSubscription != null) {
                cancelSubscription();
            }
            if (rejectPromise != null) {
                rejectPromise("cancelled by timeout");
            }
        }, this.timeoutInSeconds * 1000);


        // It will run only one time, if you prefer, you can create this document manually on the Firebase Console
        if (!(await ref.get()).exists) {
            await ref.set(Object.assign(this.createDocumentForTheFirstTime() ?? {}, { "locksQueue": [] }));
        }

        const mutexId = this.getMutexId(input);

        let finished = false;
        const finish = async () => {
            try {
                if (finished) return;
                finished = true;
                clearTimeout(timeoutId);
                if (cancelSubscription != null) cancelSubscription();
                await ref.update({ "locksQueue": FieldValue.arrayRemove(mutexId) });
            } catch (e) {
                console.error(`Could not finish: ${e.toString()}`);
            }
        };

        try {
            await ref.update({"locksQueue": FieldValue.arrayUnion(mutexId),});

            const result = await new Promise<RESULT>((resolve, reject) => {
                rejectPromise = reject;
                cancelSubscription = ref.onSnapshot(async (d) => {
                    const data = d.data();
                    if (pendingUpdate && data["locksQueue"][0] == mutexId) {
                        pendingUpdate = false;
                        const res = await this.synchronized(input, data, ref);
                        resolve(res);
                        cancelSubscription();
                    }
                }, async error => {
                    console.error(error);
                    await finish();
                    reject(error);
                }, );
            });
            await finish();
            return result;
        } catch (e) {
            console.error(e);
            await finish();
            throw e;
        }
    }

}
