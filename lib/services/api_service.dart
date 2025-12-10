import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stadium_model.dart';

class ApiService {
  static const String _url =
      'https://script.googleusercontent.com/macros/echo?user_content_key=AehSKLj9Kkh0lz56y1wYNzsq5rW3foUzdnm_btEEs2QbM7NmstokZV20ihluoOpNBDNm1tZSM1iTJoigGoHrqpVXnb9VC3zhURkuxe85heMnNllb1TL4syHv1A2PoM8Gz7WlSqI8WR5dmbv9XQdyYOUBB4AZ7TkivMrFThYupmqp5zbR4F42JUbDrTY7jxWFOMyEukDyW3J6Bkh65Pgz_wux3ZJ8Z0yC1gBXUWd4h6tqYQP7CQG7UqpoJK5d3k9tTbeslmXdFgoejGx0ZC-4JI7ZAiojAi9uEow4rcGFyBPxvyX6a6o4_VEAcHNg3mOKSQ&lib=MkAnzKyjZbLwb3t5BQ5OBOFyzx1Bqeb0r';

  Future<List<StadiumModel>> fetchStadiums() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => StadiumModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load stadiums: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }
}
