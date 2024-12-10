import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_view.dart';
import 'package:word_cloud/word_cloud_shape.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../services/dashboard.dart';

class DashboardContentsPage extends StatefulWidget {
  @override
  _DashboardContentsPageState createState() => _DashboardContentsPageState();
}

class _DashboardContentsPageState extends State<DashboardContentsPage> {
  DateRangePickerController _datePickerController = DateRangePickerController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  List<String> tweets = [];
  List<String> instas = [];
  List<String> tweetImageURLs = [];
  List<String> instaImageURLs = [];
  List<Widget> overlayImages = [];

  List<Map> _generateWordCloudData(List<String> dataList) {
    Map<String, int> wordCount = {};
    for (var word in dataList) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }
    return wordCount.entries.map((entry) {
      return {'word': entry.key, 'value': entry.value + 10};
    }).toList();
  }

  void _onDateRangeChanged(DateRangePickerSelectionChangedArgs args) {
    if (args.value is PickerDateRange) {
      PickerDateRange range = args.value;
      setState(() {
        _startDateController.text =
            DateFormat('yyyy/MM/dd').format(range.startDate!);
        _endDateController.text =
            DateFormat('yyyy/MM/dd').format(range.endDate ?? range.startDate!);
      });
    }
  }

  void _onSearch() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      _showAlertDialog(context, '\n날짜 범위를 설정하세요');
    } else {
      _contentsDateRange();
    }
  }

  void _contentsDateRange() async {
    final startDate = DateFormat('yyyy/MM/dd').parse(_startDateController.text);
    final endDate = DateFormat('yyyy/MM/dd').parse(_endDateController.text);

    try {
      final response =
          await DashboardService().contentsDateRange(startDate, endDate);
      if (mounted) {
        setState(() {
          tweets = List<String>.from(response['tweets']);
          instas = List<String>.from(response['instas']);
          tweetImageURLs = List<String>.from(response['tweetImageURLs']);
          instaImageURLs = List<String>.from(response['instaImageURLs']);
        });
        _loadOverlayImages();
      }
    } catch (e) {
      if (mounted) {
        _showAlertDialog(context, '데이터 로드 실패: $e');
      }
    }
  }

  Future<void> _loadOverlayImages() async {
    List<Widget> images = [];

    for (var url in tweetImageURLs) {
      images.add(await _loadImage(url));
    }
    for (var url in instaImageURLs) {
      images.add(await _loadImage(url));
    }
    setState(() {
      overlayImages = images;
    });
  }

  Future<Widget> _loadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final image = img.decodeImage(Uint8List.fromList(bytes));

    if (image != null) {
      return Opacity(
        opacity: 0.3,
        child: Image.memory(Uint8List.fromList(img.encodeJpg(image))),
      );
    } else {
      return SizedBox();
    }
  }

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            message,
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(10),
          content: Container(
            width: 300,
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  SfDateRangePicker(
                    controller: _datePickerController,
                    onSelectionChanged: _onDateRangeChanged,
                    selectionMode: DateRangePickerSelectionMode.range,
                    initialSelectedRange: PickerDateRange(
                      DateTime.now().subtract(Duration(days: 7)),
                      DateTime.now(),
                    ),
                    startRangeSelectionColor: Colors.blueAccent,
                    endRangeSelectionColor: Colors.blueAccent,
                    rangeSelectionColor: Colors.blueAccent.withOpacity(0.2),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map> tweetsWordList =
        tweets.isNotEmpty ? _generateWordCloudData(tweets) : [];
    List<Map> instasWordList =
        instas.isNotEmpty ? _generateWordCloudData(instas) : [];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(' ~ ', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 5),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_today,
                        color: Colors.blueAccent,
                        size: 35,
                      ),
                      onPressed: _showDateRangePicker,
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    '조 회',
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tweet Text',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsTweetText(tweetsWordList: tweetsWordList),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tweet Image',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsTweetImage(overlayImages: overlayImages),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Insta Text',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsInstaText(instasWordList: instasWordList),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Insta Image',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsInstaImage(overlayImages: overlayImages),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardContentsTweetText extends StatelessWidget {
  final List<Map> tweetsWordList;

  DashboardContentsTweetText({required this.tweetsWordList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tweetsWordList.isNotEmpty)
          WordCloudView(
            data: WordCloudData(data: tweetsWordList),
            mapcolor: Colors.white,
            mapwidth: 350,
            mapheight: 350,
            fontWeight: FontWeight.bold,
            shape: WordCloudEllipse(majoraxis: 250, minoraxis: 200),
            colorlist: [
              Color.fromRGBO(29, 107, 255, 1),
              Color.fromRGBO(0, 221, 145, 1),
              Color.fromRGBO(255, 63, 62, 1),
              Color.fromRGBO(255, 198, 52, 1),
              Color.fromRGBO(206, 105, 18, 1),
              Color.fromRGBO(110, 84, 194, 1),
              Color.fromRGBO(14, 107, 70, 1),
              Color.fromRGBO(255, 125, 169, 1),
            ],
          ),
      ],
    );
  }
}

class DashboardContentsTweetImage extends StatelessWidget {
  final List<Widget> overlayImages;

  DashboardContentsTweetImage({required this.overlayImages});

  @override
  Widget build(BuildContext context) {
    return overlayImages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: overlayImages,
          );
  }
}

class DashboardContentsInstaText extends StatelessWidget {
  final List<Map> instasWordList;

  DashboardContentsInstaText({required this.instasWordList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (instasWordList.isNotEmpty)
          WordCloudView(
            data: WordCloudData(data: instasWordList),
            mapcolor: Colors.white,
            mapwidth: 350,
            mapheight: 350,
            fontWeight: FontWeight.bold,
            shape: WordCloudEllipse(majoraxis: 250, minoraxis: 200),
            colorlist: [
              Color.fromRGBO(29, 107, 255, 1),
              Color.fromRGBO(0, 221, 145, 1),
              Color.fromRGBO(255, 63, 62, 1),
              Color.fromRGBO(255, 198, 52, 1),
              Color.fromRGBO(206, 105, 18, 1),
              Color.fromRGBO(110, 84, 194, 1),
              Color.fromRGBO(14, 107, 70, 1),
              Color.fromRGBO(255, 125, 169, 1),
            ],
          ),
      ],
    );
  }
}

class DashboardContentsInstaImage extends StatelessWidget {
  final List<Widget> overlayImages;

  DashboardContentsInstaImage({required this.overlayImages});

  @override
  Widget build(BuildContext context) {
    return overlayImages.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: overlayImages,
          );
  }
}
