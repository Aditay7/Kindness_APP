import 'package:flutter/material.dart';
import 'package:Kindness/theme/app_theme.dart';
import 'package:Kindness/utils/responsive_helper.dart';
import 'package:fl_chart/fl_chart.dart';

class ImpactReportScreen extends StatelessWidget {
  final int totalDonations;
  final int totalMealsDonated;
  final double co2Saved;
  final List<Map<String, dynamic>> ngoFeedbacks;

  const ImpactReportScreen({
    Key? key,
    required this.totalDonations,
    required this.totalMealsDonated,
    required this.co2Saved,
    required this.ngoFeedbacks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveHelper.getPaddingValue(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impact Report'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Donations',
                    totalDonations.toString(),
                    Icons.restaurant,
                  ),
                ),
                SizedBox(width: padding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Meals Donated',
                    totalMealsDonated.toString(),
                    Icons.people,
                  ),
                ),
                SizedBox(width: padding),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'CO2 Saved',
                    '${co2Saved.toStringAsFixed(1)} kg',
                    Icons.eco,
                  ),
                ),
              ],
            ),
            SizedBox(height: padding * 2),

            // Impact Overview
            Text(
              'Impact Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: padding),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: totalDonations.toDouble(),
                      title:
                          '${(totalDonations / (totalDonations + totalMealsDonated) * 100).toStringAsFixed(1)}%',
                      radius: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    PieChartSectionData(
                      value: totalMealsDonated.toDouble(),
                      title:
                          '${(totalMealsDonated / (totalDonations + totalMealsDonated) * 100).toStringAsFixed(1)}%',
                      radius: 80,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: padding * 2),

            // NGO Feedback
            Text(
              'NGO Feedback',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: padding),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ngoFeedbacks.length,
              itemBuilder: (context, index) {
                final feedback = ngoFeedbacks[index];
                return Card(
                  margin: EdgeInsets.only(bottom: padding),
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(feedback['ngoImage']),
                              radius: 20,
                            ),
                            SizedBox(width: padding),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feedback['ngoName'],
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    feedback['date'],
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: padding),
                        Text(feedback['message']),
                        SizedBox(height: padding),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(feedback['rating'].toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon) {
    final padding = ResponsiveHelper.getPaddingValue(context);
    return Card(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
