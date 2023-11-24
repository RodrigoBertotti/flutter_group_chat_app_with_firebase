


class TokensEntity {
  final String accessToken;
  final String refreshToken;
  final String uid;
  final DateTime accessTokenExpiration;

  TokensEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.uid,
    required this.accessTokenExpiration
  });
}