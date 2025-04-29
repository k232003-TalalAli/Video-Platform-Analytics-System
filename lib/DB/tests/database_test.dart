import 'package:flutter_test/flutter_test.dart';
import '../models/user.dart';
import '../models/video.dart';
import '../models/video_metric.dart';
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart';
import '../repositories/video_metric_repository.dart';

void main() {
  late UserRepository userRepository;
  late VideoRepository videoRepository;
  late VideoMetricRepository metricRepository;
  late String testUserId;
  late String testVideoId;

  setUp(() async {
    userRepository = UserRepository();
    videoRepository = VideoRepository();
    metricRepository = VideoMetricRepository();
  });

  group('User Tests', () {
    test('Add and Get User', () async {
      // Create a test user
      final user = User(
        userId: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        userName: 'Test User',
        channelCreationDate: DateTime.now(),
        channelName: 'Test Channel',
        totalViews: 0,
        totalSubs: 0,
        totalComments: 0,
        totalWatchtime: 0,
        totalRevenue: 0.0,
        channelImageLink: 'https://example.com/image.jpg',
        description: 'Test Description',
      );

      // Add user
      await userRepository.addUser(user);
      testUserId = user.userId;

      // Get user by ID
      final retrievedUser = await userRepository.getUserById(user.userId);
      expect(retrievedUser, isNotNull);
      expect(retrievedUser?.userName, equals(user.userName));
      expect(retrievedUser?.channelName, equals(user.channelName));
    });

    test('Update User', () async {
      final user = await userRepository.getUserById(testUserId);
      expect(user, isNotNull);

      if (user != null) {
        final updatedUser = User(
          userId: user.userId,
          userName: 'Updated User',
          channelCreationDate: user.channelCreationDate,
          channelName: 'Updated Channel',
          totalViews: 1000,
          totalSubs: 100,
          totalComments: 50,
          totalWatchtime: 5000,
          totalRevenue: 100.0,
          channelImageLink: user.channelImageLink,
          description: 'Updated Description',
        );

        await userRepository.updateUser(updatedUser);

        final retrievedUser = await userRepository.getUserById(testUserId);
        expect(retrievedUser?.userName, equals('Updated User'));
        expect(retrievedUser?.totalViews, equals(1000));
      }
    });
  });

  group('Video Tests', () {
    test('Add and Get Video', () async {
      // Create a test video
      final video = Video(
        videoId: 'test_video_${DateTime.now().millisecondsSinceEpoch}',
        videoName: 'Test Video',
        views: 1000,
        subs: 100,
        revenue: 50.0,
        comments: 50,
        watchtime: 5000,
        creationDate: DateTime.now(),
      );

      // Add video
      await videoRepository.addVideo(testUserId, video);
      testVideoId = video.videoId;

      // Get video by ID
      final retrievedVideo =
          await videoRepository.getVideoById(testUserId, video.videoId);
      expect(retrievedVideo, isNotNull);
      expect(retrievedVideo?.videoName, equals(video.videoName));
      expect(retrievedVideo?.views, equals(video.views));
    });

    test('Update Video', () async {
      final video = await videoRepository.getVideoById(testUserId, testVideoId);
      expect(video, isNotNull);

      if (video != null) {
        final updatedVideo = Video(
          videoId: video.videoId,
          videoName: 'Updated Video',
          views: 2000,
          subs: 200,
          revenue: 100.0,
          comments: 100,
          watchtime: 10000,
          creationDate: video.creationDate,
        );

        await videoRepository.updateVideo(testUserId, updatedVideo);

        final retrievedVideo =
            await videoRepository.getVideoById(testUserId, testVideoId);
        expect(retrievedVideo?.videoName, equals('Updated Video'));
        expect(retrievedVideo?.views, equals(2000));
      }
    });
  });

  group('Video Metric Tests', () {
    test('Add and Get Metrics', () async {
      // Create a test metric
      final metric = VideoMetric(
        metricId: 'test_metric_${DateTime.now().millisecondsSinceEpoch}',
        day: DateTime.now(),
        dayViews: 100,
        impressions: 1000,
        ctr: 0.1,
        watchtime: 500,
      );

      // Add metric
      await metricRepository.addMetric(testVideoId, metric);

      // Get metrics
      final metrics = await metricRepository.getVideoMetrics(testVideoId);
      expect(metrics, isNotEmpty);
      expect(metrics.first.dayViews, equals(100));
      expect(metrics.first.impressions, equals(1000));
    });

    test('Update Metric', () async {
      final metrics = await metricRepository.getVideoMetrics(testVideoId);
      expect(metrics, isNotEmpty);

      final metric = metrics.first;
      final updatedMetric = VideoMetric(
        metricId: metric.metricId,
        day: metric.day,
        dayViews: 200,
        impressions: 2000,
        ctr: 0.2,
        watchtime: 1000,
      );

      await metricRepository.updateMetric(testVideoId, updatedMetric);

      final retrievedMetrics =
          await metricRepository.getVideoMetrics(testVideoId);
      expect(retrievedMetrics.first.dayViews, equals(200));
      expect(retrievedMetrics.first.impressions, equals(2000));
    });

    test('Get Metrics by Date Range', () async {
      final startDate = DateTime.now().subtract(const Duration(days: 7));
      final endDate = DateTime.now().add(const Duration(days: 7));

      final metrics = await metricRepository.getMetricsByDateRange(
        testVideoId,
        startDate,
        endDate,
      );

      expect(metrics, isNotEmpty);
    });
  });
}
