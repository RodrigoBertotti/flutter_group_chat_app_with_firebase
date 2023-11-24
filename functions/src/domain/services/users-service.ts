import {usersDatasource} from "../../data/datasource/users-datasource";
import {UserFull} from "../entities/user-full";
import {UserPublic} from "../entities/user-public";
import {getAgoraUidMutexService} from "./get-agora-uid-mutex-service";


class UsersService {

    getFullUser (uid:string) : Promise<UserFull | undefined> {
        return usersDatasource.getFullUser(uid);
    }
    getPublicUser (uid:string) : Promise<UserPublic | undefined> {
        return usersDatasource.getPublicUser(uid);
    }

    updateUser(uid: string, data:any, visibility:'public'|'private') : Promise<void> {
        return usersDatasource.updateUser(uid, data, visibility);
    }

    async getAgoraUid(uid: string, cache?:UserFull) : Promise<number> {
        cache ??= await usersService.getFullUser(uid);
        if (cache.agoraUid == null) {
            cache.agoraUid = (await getAgoraUidMutexService.call({uid: uid})).agoraUid;
        }
        return cache.agoraUid;
    }

}

export const usersService = new UsersService();
