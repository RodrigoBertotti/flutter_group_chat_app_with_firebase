import {usersDatasource} from "../../data/datasource/users-datasource";
import * as admin from "firebase-admin";
import {UserFull} from "../entities/user-full";

class NotificationsService {
    async sendPushNotificationToDevice(params:{uid?:string, user?:UserFull, title:string, body:string, data?:object}): Promise<void> {
        if (params.user == null && params.uid == null) {
            throw Error("You must inform either user or uid");
        }
        params.user ??= await usersDatasource.getFullUser(params.uid!);
        if (params.user?.fcmToken?.length) {
            try {
                const data = {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    ...params.data,
                };

                await admin.messaging().send({
                    notification: {
                        title: params.title,
                        body: params.body,
                    },
                    android: {
                        notification: {
                            title: params.title,
                            body: params.body,
                            color: "#1A237E",
                        },
                        priority: "high",
                        ttl: 24 * 60 * 60,
                    },
                    webpush: {
                        notification: {
                            title: params.title,
                            body: params.body,
                            data: data,
                        }
                    },
                    token: params.user.fcmToken,
                    data: data
                });
                console.log(`Push notification sent to ${params.user.fullName} (${params.user.uid}).`);
            } catch (e:any) {
                console.error(`An error ocurred when sending the push notification to ${params.user.fullName} (${params.user.uid}): \"${e.stack.split("\n", 1).join("")}\"`);
            }
        } else {
            console.log(`Push notification NOT sent to ${(params.user?.fullName ?? 'unknown')} (${(params.user?.uid ?? 'unknown')}).`);
        }
    }
}

export const notificationsService = new NotificationsService();
