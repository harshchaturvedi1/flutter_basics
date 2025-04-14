import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class TestScreen extends StatelessWidget {
  final List<Map<String, String>> videoData = [
    {
      'url': 'https://www.w3schools.com/html/mov_bbb.mp4',
      'title': 'Big Buck Bunny',
      'description': 'A classic animation featuring Big Buck Bunny.',
      'thumbnail': 'https://www.w3schools.com/html/img_chania.jpg',
    },
    {
      'url': 'https://www.w3schools.com/html/movie.mp4',
      'title': 'W3Schools Sample Video',
      'description': 'This is a sample video from W3Schools.',
      'thumbnail': 'https://www.w3schools.com/html/img_fjords.jpg',
    },
    {
      'url': 'https://www.quirksmode.org/html5/videos/big_buck_bunny.mp4',
      'title': 'Big Buck Bunny',
      'description': 'Another classic video of Big Buck Bunny.',
      'thumbnail': 'https://www.quirksmode.org/html5/images/teaser.png',
    },
    {
      'url': 'https://www.w3schools.com/html/movie.mp4', // Example of a missing thumbnail
      'title': 'Missing Thumbnail Video',
      'description': 'This video has no thumbnail.',
      'thumbnail': 'https://example.com/invalid-image.jpg', // Invalid URL for testing
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Playlist')),
      body: ListView.builder(
        itemCount: videoData.length,
        itemBuilder: (context, index) {
          final video = videoData[index];
          return ListTile(
            leading: Image.network(
              video['thumbnail']!,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Display a blank box when the image is not found or fails to load
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300], // Blank or placeholder background color
                );
              },
            ),
            title: Text(video['title']!),
            subtitle: Text(video['description']!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullScreenVideoPlayer(url: video['url']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String url;

  const FullScreenVideoPlayer({super.key, required this.url});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing')),
      body: Center(
        child: _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
            ? Chewie(controller: _chewieController!)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
