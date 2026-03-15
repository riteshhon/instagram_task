import '../models/story.dart';
import 'base_api_service.dart';

/// API service for stories (get stories from JSON).
class StoryService extends BaseApiService {
  static const String _storiesPath = 'assets/json/stories.json';

  /// Fetches all stories from JSON file.
  Future<List<Story>> getStories() async {
    final data = await getJsonFromAsset(_storiesPath);
    final list = data['stories'] as List<dynamic>? ?? [];
    return list
        .map((e) => Story.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches a single story by id.
  Future<Story?> getStoryById(String storyId) async {
    final stories = await getStories();
    try {
      return stories.firstWhere((s) => s.id == storyId);
    } catch (_) {
      return null;
    }
  }
}
