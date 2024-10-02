import 'package:flutter/material.dart';
import '../services/dashboard.dart';

class DashboardSalesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Analysis',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardSalesAnalysis(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Prediction',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardSalesPrediction(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardSalesAnalysis extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Analysis Component'),
    );
  }
}

class DashboardSalesPrediction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Prediction Component'),
    );
  }
}
