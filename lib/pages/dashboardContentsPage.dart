import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:word_cloud/word_cloud_data.dart';
import 'package:word_cloud/word_cloud_view.dart';
import 'package:word_cloud/word_cloud_shape.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:typed_data';
import '../services/dashboard.dart';

class DashboardContentsPage extends StatefulWidget {
  @override
  _DashboardContentsPageState createState() => _DashboardContentsPageState();
}

class _DashboardContentsPageState extends State<DashboardContentsPage> {
  // Date range picker controller (날짜 범위 선택 컨트롤러)
  DateRangePickerController _datePickerController = DateRangePickerController();
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  List<String> tweets = [];
  List<String> instas = [];
  List<String> tweetImageURLs = [];
  List<String> instaImageURLs = [];
  List<Widget> tweetOverlayImages = [];
  List<Widget> instaOverlayImages = [];
  bool _imagesLoaded = false;
  bool isLoadingTweetImages = false;
  bool isLoadingInstaImages = false;

  // Generate word frequency map from text list (텍스트 리스트로부터 단어 빈도 맵 생성)
  List<Map> _generateWordCloudData(List<String> dataList) {
    final stopWords = {
      'the',
      'is',
      'a',
      'of',
      'to',
      'and',
      'in',
      'that',
      'it',
      'on',
      'for',
      'this',
      'with',
      'as',
      'was',
      'but',
      'be',
      'are',
      'at',
      'or',
      'an',
      'by'
    };

    Map<String, int> wordCount = {};
    for (var sentence in dataList) {
      final words = sentence
          .toLowerCase()
          // Remove punctuation (구두점 제거)
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .split(' ')
          // Remove stopwords (불용어 제거)
          .where((w) => w.isNotEmpty && !stopWords.contains(w));
      for (var word in words) {
        wordCount[word] = (wordCount[word] ?? 0) + 1;
      }
    }
    return wordCount.entries.map((entry) {
      // Bias count for visualization (시각화를 위한 가중치 부여)
      return {'word': entry.key, 'value': entry.value + 10};
    }).toList();
  }

  // Handle date range picker selection (날짜 범위 선택 이벤트 처리)
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

  // Trigger content loading via search (검색 버튼 클릭 시 처리)
  void _onSearch() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      // Alert on empty dates (날짜 미입력 시 알림)
      _showAlertDialog(context, '\n"Set the date range');
    } else {
      // Load contents for selected range (선택된 범위에 대한 콘텐츠 로드)
      _contentsDateRange();
    }
  }

  // Fetch data from backend for given date range (날짜 범위에 대한 데이터 백엔드 요청)
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
          _imagesLoaded = false;

          isLoadingTweetImages = true;
          isLoadingInstaImages = true;
        });

        // Asynchronously load image widgets (이미지 위젯 비동기 로드)
        await _loadOverlayImages();

        if (mounted) {
          setState(() {
            _imagesLoaded = true;
            isLoadingTweetImages = false;
            isLoadingInstaImages = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        // Error alert (데이터 로딩 실패 알림)
        _showAlertDialog(context, 'Data loading failure: $e');
      }
    }
  }

  // Load image widgets and build overlays (이미지 위젯 로드 및 오버레이 생성)
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

  // Fetch and decode image from URL (URL로부터 이미지 디코딩 및 반환)
  Future<Widget> _loadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    final image = img.decodeImage(Uint8List.fromList(bytes));

    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Opacity(
          opacity: 0.1,
          child: SizedBox(
            width: 360,
            height: 360,
            child: Image.memory(
              Uint8List.fromList(img.encodeJpg(image)),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      // Return empty if decoding fails (디코딩 실패 시 빈 위젯 반환)
      return SizedBox();
    }
  }

  // Display a styled alert dialog (스타일이 적용된 경고 다이얼로그 표시)
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Error alert',
            style: TextStyle(fontSize: 20),
          ),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                message,
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(242, 242, 242, 242),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(52, 52, 52, 52),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Open the date range picker dialog (날짜 범위 선택기 다이얼로그 열기)
  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Date range setting',
            style: TextStyle(fontSize: 20),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SfDateRangePicker(
                          controller: _datePickerController,
                          onSelectionChanged: _onDateRangeChanged,
                          selectionMode: DateRangePickerSelectionMode.range,
                          initialSelectedRange: PickerDateRange(
                            DateTime.now().subtract(Duration(days: 7)),
                            DateTime.now(),
                          ),
                          startRangeSelectionColor: Color(0xFF44558C8),
                          endRangeSelectionColor: Color(0xFF44558C8),
                          rangeSelectionColor:
                              Color(0xFF44558C8).withOpacity(0.2),
                          backgroundColor: Colors.transparent,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF44558C8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: SizedBox(
                            width: 360,
                            child: Center(
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(242, 242, 242, 242),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(52, 52, 52, 52),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateInputSection(),
            SizedBox(height: 30),
            _buildSection('Tweet Text'),
            SizedBox(height: 10),
            DashboardContentsTweetText(tweetsWordList: tweetsWordList),
            SizedBox(height: 30),
            _buildSection('Tweet Image'),
            SizedBox(height: 10),
            DashboardContentsTweetImage(
              overlayImages: tweetOverlayImages,
              isLoading: isLoadingTweetImages,
            ),
            SizedBox(height: 30),
            _buildSection('Insta Text'),
            SizedBox(height: 10),
            DashboardContentsInstaText(instasWordList: instasWordList),
            SizedBox(height: 30),
            _buildSection('Insta Image'),
            SizedBox(height: 10),
            DashboardContentsInstaImage(
              overlayImages: instaOverlayImages,
              isLoading: isLoadingInstaImages,
            ),
          ],
        ),
      ),
    );
  }

  // Build date input section UI (날짜 입력 UI 구성)
  Widget _buildDateInputSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _startDateController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: _inputDecoration('Start date'),
              ),
            ),
            Text(' ~ ', style: TextStyle(fontSize: 18)),
            Expanded(
              child: TextFormField(
                controller: _endDateController,
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: _inputDecoration('End date'),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 360,
          child: ElevatedButton(
            onPressed: _showDateRangePicker,
            child: Text(
              'Set dates',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52)),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(242, 242, 242, 242),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        SizedBox(
          width: 360,
          child: ElevatedButton(
            onPressed: _onSearch,
            child: Text(
              'Get results',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF44558C8),
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Input decoration with uniform styling (일관된 입력창 스타일 설정)
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  // Common button style generator (공통 버튼 스타일 생성기)
  ButtonStyle _btnStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  // Section title builder (섹션 제목 UI 생성)
  Widget _buildSection(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Color.fromRGBO(52, 52, 52, 52),
      ),
    );
  }
}

// Overlay image display for tweet section (트윗 이미지 오버레이 표시 위젯)
class DashboardContentsTweetImage extends StatelessWidget {
  final List<Widget> overlayImages;
  final bool isLoading;
  DashboardContentsTweetImage({
    required this.overlayImages,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (overlayImages.isEmpty) return SizedBox();
    return SizedBox(
      width: 360,
      height: 360,
      child: Stack(children: overlayImages),
    );
  }
}

// Overlay image display for Instagram section (인스타 이미지 오버레이 표시 위젯)
class DashboardContentsInstaImage extends StatelessWidget {
  final List<Widget> overlayImages;
  final bool isLoading;
  DashboardContentsInstaImage({
    required this.overlayImages,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());
    if (overlayImages.isEmpty) return SizedBox();
    return SizedBox(
      width: 360,
      height: 360,
      child: Stack(children: overlayImages),
    );
  }
}

// Word cloud visualization for tweets (트윗 텍스트 워드클라우드 시각화)
class DashboardContentsTweetText extends StatelessWidget {
  final List<Map> tweetsWordList;
  DashboardContentsTweetText({required this.tweetsWordList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (tweetsWordList.isNotEmpty)
          WordCloudView(
            data: WordCloudData(data: tweetsWordList),
            mapcolor: Colors.white,
            mapwidth: 350,
            mapheight: 350,
            fontWeight: FontWeight.bold,
            shape: WordCloudEllipse(
              majoraxis: 300,
              minoraxis: 250,
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

// Word cloud visualization for Instagram texts (인스타 텍스트 워드클라우드 시각화)
class DashboardContentsInstaText extends StatelessWidget {
  final List<Map> instasWordList;
  DashboardContentsInstaText({required this.instasWordList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (instasWordList.isNotEmpty)
          WordCloudView(
            data: WordCloudData(data: instasWordList),
            mapcolor: Colors.white,
            mapwidth: 350,
            mapheight: 350,
            fontWeight: FontWeight.bold,
            shape: WordCloudEllipse(
              majoraxis: 300,
              minoraxis: 250,
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
