import 'dart:io';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';
import 'package:polyline_codec/polyline_codec.dart';

class GPXHelper {

  static List<List<double>> gpxToLatLong (String gpx) {
    var coordPairs = <List<double>>[];
    // Read all track points
    final document = XmlDocument.parse(gpx);
    final points = document.xpath("/gpx/trk/trkseg/trkpt");
    for (var point in points) {
      double lat = double.parse(point.getAttribute("lat")!);
      double lon = double.parse(point.getAttribute("lon")!);
      // Round to 6 decimal places
      lat = (lat*1000000).round()/1000000;
      lon = (lon*1000000).round()/1000000;
      coordPairs.add([lat, lon]);
    }
    return coordPairs;
  }

  static String coordsToPolyline (List<List<double>> coordinates) {
    return PolylineCodec.encode(coordinates);
  }

  static Future<String> readFromFile(String filePath) async {
    final file = await rootBundle.loadString(filePath);
    return file;
  }
}