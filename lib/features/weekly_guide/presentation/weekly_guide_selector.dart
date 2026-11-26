import 'package:material_ui/material_ui.dart';

import 'weekly_guide_screen.dart';

class WeeklyGuideSelector extends StatelessWidget {
  final int currentWeek;

  const WeeklyGuideSelector({super.key, required this.currentWeek});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 40,
        itemBuilder: (context, index) {
          final week = index + 1;
          final isSelected = week == currentWeek;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyGuideScreen(week: week),
                ),
              );
            },
            child: Container(
              width: 70,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.pinkAccent : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.pinkAccent),
              ),
              child: Center(
                child: Text(
                  '$week',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.pinkAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
