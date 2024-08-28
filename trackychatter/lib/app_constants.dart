import 'package:latlong2/latlong.dart';

class AppConstants {
  static const String mapBoxAccessToken =
      'pk.eyJ1IjoibGFtYmljaDA0MTEiLCJhIjoiY2x5c3ZxYzdtMDV0NzJxcHNpeDIwM2pmYSJ9.rCt6pCMeHE3A97fK4AE3pg';

  static const String urlTemplate =
      'https://api.mapbox.com/styles/v1/{id}/tiles/256/{z}/{x}/{y}@2x?access_token=$mapBoxAccessToken';
  static const String mapBoxStyleDarkId = 'mapbox/dark-v11';
  static const String mapBoxStyleOutdoorId = 'mapbox/outdoors-v12';
  static const String mapBoxStyleStreetId = 'mapbox/streets-v12';
  static const String mapBoxStyleNightId = 'mapbox/navigation-night-v1';

  static const myLocation = LatLng(51.5, -0.09);
}
