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
  List<Widget> tweetOverlayImages = [];
  List<Widget> instaOverlayImages = [];

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
      _showAlertDialog(context, '\n"Set the date range');
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
    List<Widget> tweetImages = [];
    for (var url in tweetImageURLs) {
      tweetImages.add(await _loadImage(url));
    }
    List<Widget> instaImages = [];
    for (var url in instaImageURLs) {
      instaImages.add(await _loadImage(url));
    }
    setState(() {
      tweetOverlayImages = tweetImages;
      instaOverlayImages = instaImages;
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
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Start date',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF44558C8),
                              width: 1.5,
                            ),
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Text(' ~ ', style: TextStyle(fontSize: 18)),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'End date',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(
                              color: Color(0xFF44558C8),
                              width: 1.5,
                            ),
                          ),
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(242, 242, 242, 242),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  _showDateRangePicker();
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      'Set date range',
                      style: TextStyle(
                        color: Color.fromRGBO(52, 52, 52, 52),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF44558C8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  _onSearch();
                },
                child: SizedBox(
                  width: 360,
                  child: Center(
                    child: Text(
                      'Get Results',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                child: Text(
                  'Tweet Text',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
                  ),
                ),
              ),
              DashboardContentsTweetText(tweetsWordList: tweetsWordList),
              SizedBox(height: 20),
              Container(
                child: Text(
                  'Tweet Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
                  ),
                ),
              ),
              DashboardContentsTweetImage(overlayImages: tweetOverlayImages),
              SizedBox(height: 20),
              Container(
                child: Text(
                  'Insta Text',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
                  ),
                ),
              ),
              DashboardContentsInstaText(instasWordList: instasWordList),
              SizedBox(height: 20),
              Container(
                child: Text(
                  'Insta Image',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
                  ),
                ),
              ),
              DashboardContentsInstaImage(overlayImages: instaOverlayImages),
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
            mapwidth: 360,
            mapheight: 360,
            fontWeight: FontWeight.bold,
            shape: WordCloudEllipse(
              majoraxis: 250,
              minoraxis: 200,
            ),
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
            mapwidth: 360,
            mapheight: 360,
            fontWeight: FontWeight.bold,
            shape: WordCloudEllipse(
              majoraxis: 250,
              minoraxis: 200,
            ),
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
