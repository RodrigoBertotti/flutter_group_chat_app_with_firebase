import {firestore} from "firebase-admin";

export function db () {
    return firestore();
}
