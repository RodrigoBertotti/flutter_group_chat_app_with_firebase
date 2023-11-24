import * as functions from "firebase-functions";

export const onCallWrapper = async (handler: () => any | Promise<any>) : Promise<any> => {
    try {
        return (await handler());
    } catch (e) {
        console.error(e.toString());
        throw new functions.https.HttpsError("unknown", "An internal error occurred");
    }
}
