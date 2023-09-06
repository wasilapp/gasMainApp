import 'package:EMallApp/utils/TextUtils.dart';

class Account{

  int? id;
  String? name, email,mobile ,token, avatarUrl;

  Account(this.id,this.name, this.email,this.mobile, this.token, this.avatarUrl);

  Account.empty() {
    id=null;
    name = "";
    email = "";
    token = "";
  }

  getAvatarUrl() {
    return TextUtils.getImageUrl(avatarUrl??"");
  }



}