



export class UserPublic {

    constructor(
       public readonly uid: string,
       public readonly firstName: string,
       public readonly lastName: string,
       public agoraUid: number,
    ) {}

    get fullName () : string {
        return `${this.firstName} ${this.lastName}`;
    }

}
