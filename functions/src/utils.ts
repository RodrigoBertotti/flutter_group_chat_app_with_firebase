import * as admin from "firebase-admin"


export function fromMapOfTimestamp (map:any): Map<String,Date> {
    const res: Map<String,Date> = new Map();
    for (const key of Object.keys(map)) {
        if (map.hasOwnProperty(key)) {
            res[key] = (map[key] as admin.firestore.Timestamp)?.toDate();
        }
    }
    return res;
}
