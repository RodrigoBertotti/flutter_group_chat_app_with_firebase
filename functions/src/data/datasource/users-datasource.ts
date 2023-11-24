import {UserPublic} from "../../domain/entities/user-public";
import {UserFull} from "../../domain/entities/user-full";
import {db} from "./db";
import {UserPublicModel} from "../models/user-public-model";
import {UserFullModel} from "../models/user-full-model";


class UsersDatasource {

    async getPublicUser (uid:string) : Promise<UserPublicModel | null> {
        const user = await this.publicUserRef(uid).get();

        return UserPublicModel.fromData(user.data());
    }

    private publicUserRef(uid: string) {
        return db()
            .collection("users")
            .doc(uid);
    }
    private fullUserRef(uid: string) {
        return db()
            .collection("users")
            .doc(uid)
            .collection("fullUser")
            .doc("data");
    }

    async getFullUser (uid:string) : Promise<UserFullModel | undefined> {
        const user = await this.fullUserRef(uid).get();

        return UserFullModel.fromData(user.data());
    }

    async updateUser(uid: string, data: {[p: string]: any} & FirebaseFirestore.AddPrefixToKeys<string, any>, visibility:'public'|'private'): Promise<void> {
        if (visibility == "public") {
            await this.publicUserRef(uid).update(data);
        }
        await this.fullUserRef(uid).update(data);
    }
}

export const usersDatasource = new UsersDatasource();
