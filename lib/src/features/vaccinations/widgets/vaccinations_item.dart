import 'package:flutter/material.dart';

class VaccinationsItem extends StatelessWidget {
  final String id;
  final String name;
  final String describtion;
  VaccinationsItem({
    this.id,
    this.name,
    this.describtion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            color: Colors.grey[200],
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.display2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        describtion,
                        style: Theme.of(context)
                            .textTheme
                            .display2
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
